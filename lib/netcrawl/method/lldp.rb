require_relative '../snmp'
class NetCrawl
  class LLDP
    include NameMap
    OID = {
      # http://standards.ieee.org/getieee802/download/802.1AB-2009.pdf
      :lldpRemChassisIdSubtype => '1.0.8802.1.1.2.1.4.1.1.4', # CSCO and JNPR use 4 (MAC address) rendering ChassisID useless
      :lldpRemChassisId        => '1.0.8802.1.1.2.1.4.1.1.5',
      :lldpRemSysName          => '1.0.8802.1.1.2.1.4.1.1.9',
    }

    # @param [String] host host to query
    # @return [Hash] neighbor information
    def self.get host
      lldp = new(host)
      lldp.peers
    end

    def peers
      @snmp.bulkwalk(OID[:lldpRemSysName]).map do |vb|
        DNS.getip namemap(vb.value)
      end.compact
    rescue SNMP::NoResponse
      []
    end

    private

    def initialize host
      @snmp = SNMP.new host
    end


  end
end
