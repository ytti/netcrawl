require_relative 'netcrawl/config'
class NetCrawl
  class NetCrawlError < StandardError; end
  class MethodNotFound < NetCrawlError; end
  attr_reader :hosts

  # @param [String] host host to start crawl from
  # @return [NetCrawl::Output]
  def crawl host
    recurse host
    Output.new @hosts, @poll
  end

  # @param [String] host host to get list of peers from
  # @return [Array] list of peers seen connected to host
  def get host
    peers = []
    @methods.each do |method|
      peers += method.send(:peers, host)
    end
    peers.uniq { |peer| peer.ip }
  end

  # Given string of IP address, recurses through peers seen and populates @hosts hash
  # @param [String] host host to start recurse from
  # @return [void]
  def recurse host
    peers = get host
    @hosts[host] = peers
    peers.each do |peer|
      next if     @hosts.has_key? peer.ip
      next unless @poll.include?  peer.ip
      crawl peer.ip
    end
  end

  private

  def initialize
    @methods = []
    @hosts   = {}
    @poll    = PollMap.new
    CFG.use.each do |method|
      begin
        method = File.basename method.to_s
        file = 'netcrawl/method/' + method.downcase
        require_relative file
        @methods.push NetCrawl.const_get(method)
      rescue NameError, LoadError
        raise MethodNotFound, "unable to find method '#{method}'"
      end
    end
  end


end
require_relative 'netcrawl/pollmap'
require_relative 'netcrawl/namemap'
require_relative 'netcrawl/peer'
require_relative 'netcrawl/method/xdp'
require_relative 'netcrawl/dns'
require_relative 'netcrawl/output'
