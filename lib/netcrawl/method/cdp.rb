require_relative '../snmp'
class NetCrawl
  class CDP
    OID = {
      # http://tools.cisco.com/Support/SNMP/do/BrowseOID.do?local=en&translate=Translate&objectInput=1.3.6.1.4.1.9.9.23.1.2.1.1
      :cdpCacheAddress  => '1.3.6.1.4.1.9.9.23.1.2.1.1.4',
      :cdpCacheDeviceId => '1.3.6.1.4.1.9.9.23.1.2.1.1.6',
    }

    # @param [String] host host to query
    # @return [Hash] neighbor information
    def self.get host
      cdp = new(host)
      cdp.peers
    end

    def peers
      @snmp.bulkwalk(OID[:cdpCacheAddress]).map do |vb|
        vb.as_ip
      end
    rescue SNMP::NoResponse
      []
    end

    private

    def initialize host
      @snmp = SNMP.new host
    end


  end
end
