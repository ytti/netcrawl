require 'snmp'
class NetCrawl
  class SNMP
    class NoResponse < NetCrawlError; end
    # Closes the SNMP connection
    # @return [void]
    def close
      @snmp.close
    end

    # Gets one oid, return value
    # @param [String] oid to get
    # @return [SNMP::VarBind]
    def get oid
      mget([oid]).first
    end

    # Get multiple oids, return array of values
    # @param [Array(String)] oids to get
    # @return [SNMP::VarBindList]
    def mget oids
      snmp :get, oids
    end

    # Bulkwalk everything below root oid
    # @param [String] root oid to start from
    # @return [Array(SNMP::VarBind)]
    def bulkwalk root
      last, oid, results = false, root.dup, []
      root = root.split('.').map{|chr|chr.to_i}
      while not last
        vbs = snmp(:get_bulk, 0, CFG.snmp.bulkrows, oid).varbind_list
        vbs.each do |vb|
          oid = vb.oid
          (last = true; break) if not oid[0..root.size-1] == root
          results.push vb
        end
      end
      results
    end

    private

    def initialize host, community=CFG.snmp.community, timeout=CFG.snmp.timeout, retries=CFG.snmp.retries
      @host = host
      @snmp = ::SNMP::Manager.new :Host=>@host, :Community=>community,
                                  :Timeout=>timeout, :Retries=>retries,
                                  :MibModules=>[]
    end

    def snmp cmd, *args
      @snmp.send cmd, *args
    rescue ::SNMP::RequestTimeout, Errno::EACCES => error
      msg = "host '#{@host}' raised '#{error.class}' with message '#{error.message}' for method '#{cmd}' with args '#{args}'"
      Log.warn msg
      raise NoResponse, msg
    end

  end
end

module SNMP
  class VarBind
    def as_ip
      SNMP::IpAddress.new(value).to_s
    end
  end
end
