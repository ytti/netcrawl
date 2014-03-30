require 'resolv'
class NetCrawl
  class Resolve

    # @param [String] name DNS name which we try to resolve to IP
    # @return [String, nil] string if name resolves to IP, otherwise nil
    def getip name
      if @cacheip.has_key? name
        @cacheip[name]
      else
        ip = nil
        begin
          if CFG.dns.afi == 'ipv4'
            ip = Resolv::DNS.new.getresource(name, Resolv::DNS::Resource::IN::A).address
          elsif CFG.dns.afi == 'ipv6'
            ip = Resolv::DNS.new.getresource(name, Resolv::DNS::Resource::IN::AAAA).address
          else
            ip = Resolv.getaddress name
          end
        rescue => error
          Log.debug "DNS resolution for '#{name}' raised error '#{error.class}' with message '#{error.message}'"
          return nil
        end
        @cacheip[name] = ip
      end
    end

    # @param [String] ip DNS IP which we try to resolve to name
    # @return [String] name if it resolves, ip otherwise
    def getname ip
      if @cachename.has_key? ip
        @cachename[ip]
      else
        name = nil
        begin
          name = Resolv.getname ip
        rescue => error
          Log.debug "DNS resolution for '#{ip}' raised error '#{error.class}' with message '#{error.message}'"
          name = ip
        end
        @cachename[ip] = name
      end
    end

    private

    def initialize
      @cacheip = {}
      @cachename = {}
    end
  end
  DNS = Resolve.new
end
