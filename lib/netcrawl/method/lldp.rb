class NetCrawl
  class LLDP < XDP
    MIB = '1.0.8802.1.1.2' # lldpMIB
    OID = {
      # http://standards.ieee.org/getieee802/download/802.1AB-2009.pdf
      # finding IP address for LLDP neighbour as of JunOS 13.3R1 and IOS 15.0(2)SG8 is not practical
      # ifsubtype is ifindex but value 0 for JunOS neighbours
      # ifsubtype is systemportnumber for IOS neighbours (what ever that is)
      # luckily some IP address is in the OID key itself, while dodgy, better than nothing
      #   in JunOS it was some random RFC1918 address in VRF interface, not something I could poll
      #   .1.0.8802.1.1.2.1.4.2.1.3.0.134.10.1.4.10.0.0.4
      #   in IOS it was usable address
      #   .1.0.8802.1.1.2.1.4.2.1.3.0.257.1.1.4.62.243.146.245
      #   (1.4 is IPv4)
      #  as well LocPortId/RemPortId is hard, it is 'local' (snmpifindex really) in JunOS, but ifName in IOS
      :lldpLocPortId           => '1.0.8802.1.1.2.1.3.7.1.3',
      :lldpRemChassisIdSubtype => '1.0.8802.1.1.2.1.4.1.1.4', # CSCO and JNPR use 4 (MAC address) rendering ChassisID useless
      :lldpRemChassisId        => '1.0.8802.1.1.2.1.4.1.1.5',
      :lldpRemPortIdSubtype    => '1.0.8802.1.1.2.1.4.1.1.6',
      :lldpRemPortId           => '1.0.8802.1.1.2.1.4.1.1.7',
      :lldpRemSysName          => '1.0.8802.1.1.2.1.4.1.1.9',
      :lldpRemManAddrIfSubtype => '1.0.8802.1.1.2.1.4.2.1.3',
    }
    PEERS_BY = OID[:lldpRemChassisId]
    PortSubType = {
      :mac_address => 3,
    }

    private

    def make_peers
      peers = []
      @mib.by_oid(PEERS_BY).each do |_, vb|
        peer          = Peer.new
        peer_id       = vb.oid_id(PEERS_BY)
        peer.oid      = get_oid_hash peer_id
        ip            = @mib.by_partial OID[:lldpRemManAddrIfSubtype], peer_id
        peer.raw_ip   = ip.oid[-4..-1].join('.') if ip # FIXME: IPv4 specific 
        peer.raw_name = @mib[OID[:lldpRemSysName], peer_id].value
        peer.ip       = get_ip peer.raw_ip, peer.raw_name
        peer.dst      = @mib[OID[:lldpRemPortId], peer_id].value
        if @mib[OID[:lldpRemPortIdSubtype], peer_id].value.to_i == PortSubType[:mac_address]
          peer.dst    = peer.dst.each_char.map{|e|"%02x" % e.ord}.join.scan(/..../).join('.')
        end
        peer.src      = @mib[OID[:lldpLocPortId], peer_id[1]].value
        peers << peer
      end
      peers
    end

  end
end
