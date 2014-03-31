require_relative '../snmp'
class NetCrawl
  class LLDP
    include NameMap
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
      :lldpRemChassisIdSubtype => '1.0.8802.1.1.2.1.4.1.1.4', # CSCO and JNPR use 4 (MAC address) rendering ChassisID useless
      :lldpRemChassisId        => '1.0.8802.1.1.2.1.4.1.1.5',
      :lldpRemSysName          => '1.0.8802.1.1.2.1.4.1.1.9',
      :lldpRemManAddrIfSubtype => '1.0.8802.1.1.2.1.4.2.1.3',
    }

    # @param [String] host host to query
    # @return [Hash] neighbor information
    def self.get host
      lldp = new(host)
      lldp.peers
    end

    def peers
      addrs = @snmp.walk2hash(OID[:lldpRemManAddrIfSubtype]) do |vb|
        key = vb.oid[OID[:lldpRemManAddrIfSubtype].split('.').size .. -7]
        [vb.oid.last(4).join('.'), key]
      end  # FIXME: I am IPv4 specific and generally dodgy
      names = @snmp.walk2hash(OID[:lldpRemSysName]) { |vb| DNS.getip namemap(vb.value) }
      names.keys.map { |id| names[id] or addrs[id] }.compact
    rescue SNMP::NoResponse
      []
    end

    private

    def initialize host
      @snmp = SNMP.new host
    end

  end
end
