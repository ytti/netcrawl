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

    # bulkwalks oid and returns hash with oid as key
    # @param [String] oid root oid to walk
    # @yield [VBHash] hash containing oids found
    # @return [Hash] resulting hash
    def hashwalk oid, &block
      hash  = VBHash.new
      bulkwalk(oid).each do |vb|
        #value, key = block.call(vb)
        key ||= vb.oid
        hash[key] = vb
      end
      hash
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

    # Hash with some helper methods to easier work with VarBinds
    class VBHash < Hash
      alias :org_bracket :[]
      undef :[]

      # @param [Array(Strin, Array)] oid root oid under which you want all oids below it
      # @return [VBHash] oids which start with param oid
      def by_oid *oid
        oid = arg_to_oid(*oid)
        hash = select do |key, value|
          key[0..oid.size-1] == oid
        end
        newhash = VBHash.new
        newhash.merge hash
      end

      # @param [Array(String, Array)] args partial match 3.4.6 would match to 1.2.3.4.6.7.8
      # @return [SNMP::VarBind] matching element
      def by_partial *args
        oid = arg_to_oid(*args)
        got = nil
        keys.each do |key|
          if key.each_cons(oid.size).find{|e|e==oid}
            got = self[key]
            break
          end
        end
        got
      end

      # @param [Array[String, Array)] key which you want, multiple arguments compiled into single key
      # @return [SNMP::VarBind] matching element
      def [] *args
        org_bracket arg_to_oid(*args)
      end

      private

      def arg_to_oid *args
        key = []
        args.each do |arg|
          if Array === arg
            key += arg.map{|e|e.to_i}
          elsif Fixnum === arg
            key << arg
          else
            key += arg.split('.').map{|e|e.to_i}
          end
        end
        key
      end
    end
  end
end

module SNMP
  class VarBind
    # @return [String] VarBind value as IP address
    def as_ip
      SNMP::IpAddress.new(value).to_s
    end
    # @param [String] root oid which is removed from self.oid
    # @return [Array] oid remaining after specified root oid
    def oid_id root
      root = root.split('.').map{|e|e.to_i}
      oid[root.size..-1]
    end
  end
end
