require 'ipaddr'
class NetCrawl
  class PollMap
    def initialize
      @poll = CFG.poll.map do |cidr|
        IPAddr.new cidr
      end
    end
    def include? addr
      @poll.any? { |cidr| cidr.include? addr }
    end
  end
end
