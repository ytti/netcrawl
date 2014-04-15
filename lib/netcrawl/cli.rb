require_relative '../netcrawl'
require 'slop'

class NetCrawl
  class CLI
    class MissingHost < NetCrawlError; end
    class NoConfig < NetCrawlError; end

    def run
      output = NetCrawl.new.crawl @host
      output.clean!   if @opts[:purge]
      output.resolve! if @opts[:resolve]
      if @opts[:graphviz]
        output.to_dot
      elsif @opts[:list]
        output.to_list
      elsif @opts[:json]
        output.to_json
      elsif @opts[:yaml]
        output.to_yaml
      else
        output.to_hash
      end
    end

    private

    def initialize
      raise NoConfig, 'edit ~/.config/netcrawl/config'if Config.create
      @opts = opt_parse
      args  = @opts.parse
      @host = DNS.getip args.shift
      CFG.snmp.community = @opts[:community] if @opts[:community]
      CFG.debug          = true if @opts[:debug]
      CFG.ipname         = true if @opts[:ipname]
      raise MissingHost, 'no hostname given as argument' unless @host
    end


    def opt_parse
      Slop.parse(:help=>true) do
        banner 'Usage: netcrawl [options] hostname'
        on 'g',  'graphviz',  'dot output use \'dot -Tpng -o map.png map.dot\''
        on 'l',  'list',      'list nodes'
        on 'j',  'json',      'json output'
        on 'y',  'yaml',      'yaml output'
        on 'a',  'hash',      'hash/associative array output'
        on 'r',  'resolve',   'resolve addresses to names'
        on 'p',  'purge',     'remove peers not in configured CIDR'
        on 'c=', 'community', 'SNMP community to use'
        on 'd',  'debug',     'turn debugging on'
        on 'i',  'ipname',    'use rev(ip) name instead of discovered name'
      end
    end

  end
end
