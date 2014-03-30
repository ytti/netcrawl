class NetCrawl
  class Output
    class Dot
      INDENT = ' ' * 2
      DEFAULT_COLOR = 'black'
      def self.output output
        new(output).to_s
      end

      def to_s
        str = "graph NetCrawl {\n"
        @output.to_list.each do |host|
          str << INDENT + id(host) + "[color=\"#{color(host)}\"]\n"
          str << INDENT + id(host) + "[label=\"#{host}\"]\n"
          if @hash.has_key? host
            @hash[host].each do |peer|
              next if not CFG.dot.bothlinks and @connections.include?([peer, host].sort)
              @connections << [peer, host].sort
              str << INDENT + INDENT + id(host) + ' -- ' + id(peer) + "\n"
            end
          end
        end
        str << "}\n"
        str
      end

      private

      def initialize output
        @output      = output
        @connections = []
        @hash        = @output.hash
      end

      def id host
        host = host.gsub(/[-.]/, '_')
        '_' + host
      end

      def color host
        color = nil
        CFG.dot.color.each do |re, clr|
          if host.match re
            color = clr
            break
          end
        end
        color or DEFAULT_COLOR
      end
    end
  end
end

