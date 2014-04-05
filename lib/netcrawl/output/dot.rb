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
          host_label = label(host)
          str << INDENT + id(host) + "[label=\"#{host_label}\" color=\"#{color(host_label)}\"]\n"
          if @peers.has_key? host
            @peers[host].each do |peer|
              peer_name = @resolve ? peer.name : peer.ip
              next if not CFG.dot.bothlinks and @connections.include?([peer_name, host].sort)
              @connections << [peer_name, host].sort
              labels = ''
              labels = "[headlabel=\"#{peer.dst.to_s}\" taillabel=\"#{peer.src.to_s}\"]" if CFG.dot.linklabel
              str << INDENT + INDENT + id(host) + ' -- ' + id(peer_name) + labels + "\n"
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
        @peers       = @output.peers
        @resolve     = @output.resolve
      end

      def id host
        host = host.gsub(/[-.]/, '_')
        '_' + host
      end

      def label wanthost
        label = nil
        return wanthost if CFG.ipname == true
        @peers.each do |host, peers|
          peers.each do |peer|
            gothost = @resolve ? peer.name : peer.ip
            if wanthost == gothost
              label = peer.raw_name
              break
            end
          end
          break if label
        end
        label or wanthost
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

