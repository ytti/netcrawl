require_relative '../snmp'
class NetCrawl
  class XDP
    attr_reader :mib
    include NameMap

    # @param [String] host host to query
    # @return [Array(NetCrawl::Peer)] neighbor information
    def self.peers host
      new(host).poll
    end

    def poll
      @mib = @snmp.hashwalk self.class::MIB
      make_peers
    rescue SNMP::NoResponse
      []
    end

    private

    def initialize host
      @snmp = SNMP.new host
    end

    def get_ip ip, name
      name = DNS.getip namemap(name)
      name or ip
    end

    def get_oid_hash peer_id
      oid_hash = {}
      self.class::OID.each do |name, oid|
        oid_hash[name] = @mib[oid, peer_id]
      end
      oid_hash
    end
  end
end
require_relative 'cdp'
require_relative 'lldp'
