class NetCrawl
  class Peer
    attr_accessor :ip, :raw_ip, :raw_name, :src, :dst, :oid
    def initialize
      @ip       = nil  # Best guess of system IP
      @name     = nil  # Reverse of said IP
      @raw_ip   = nil  # IP as seen in polling
      @raw_name = nil  # Name as seen in polling
      @src      = nil  # SRC/local interface
      @dst      = nil  # DSR/remote interface
      @oid      = {}   # Hash of oids collected
    end
    def name
      @name ||= DNS.getname @ip
    end
    def to_hash
      {
        'ip'   => ip.to_s,
        'name' => name.to_s,
        'interface' => {
           'source' => src.to_s,
           'destination' => dst.to_s,
        },
        'raw' => {
          'ip'   => raw_ip.to_s,
          'name' => raw_name.to_s,
        },
      }
    end
  end
end
