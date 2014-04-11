class NetCrawl
  class CDP < XDP
    MIB = '1.3.6.1.4.1.9.9.23'  # ciscoCdpMIB
    OID = {
      # http://tools.cisco.com/Support/SNMP/do/BrowseOID.do?local=en&translate=Translate&objectInput=1.3.6.1.4.1.9.9.23.1.2.1.1
      :cdpInterfaceName   => '1.3.6.1.4.1.9.9.23.1.1.1.1.6',
      :cdpCacheAddress    => '1.3.6.1.4.1.9.9.23.1.2.1.1.4',
      :cdpCacheDeviceId   => '1.3.6.1.4.1.9.9.23.1.2.1.1.6',
      :cdpCacheDevicePort => '1.3.6.1.4.1.9.9.23.1.2.1.1.7',
    }
    PEERS_BY = OID[:cdpCacheDeviceId]

    private

    def make_peers
      peers = []
      @mib.by_oid(PEERS_BY).each do |_, vb|
        peer          = Peer.new
        peer_id       = vb.oid_id(PEERS_BY)
        peer.oid      = get_oid_hash peer_id
        peer.raw_ip   = @mib[OID[:cdpCacheAddress], peer_id].as_ip
        peer.raw_name = @mib[OID[:cdpCacheDeviceId], peer_id].value
        peer.ip       = get_ip peer.raw_ip, peer.raw_name
        peer.dst      = @mib[OID[:cdpCacheDevicePort], peer_id].value
        peer.src      = @mib[OID[:cdpInterfaceName], peer_id.first]
        peer.src      = peer.src.value if peer.src
        peer.raw_ip   = @mib[OID[:cdpCacheAddress], peer_id].value
        peers << peer
      end
      peers
    end

  end
end
