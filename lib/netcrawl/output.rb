class NetCrawl
  class Output
    attr_reader :iphash, :namehash, :hash

    # @return [String] pretty print of hash
    def to_hash
      require 'pp'
      out = ''
      PP.pp @hash, out
      out
    end

    # @return [String] yaml of hosts and peers found
    def to_yaml
      require 'yaml'
      YAML.dump @hash
    end

    # @return [String] json of hosts and peers found
    def to_json
      require 'json'
      JSON.pretty_generate @hash
    end

    # @return [Array] of nodes found
    def to_list
      nodes = []
      @hash.each do |host, peers|
        nodes << host
        nodes << peers
      end
      nodes.flatten.uniq.sort
    end

    # resolves ip addresses and changes @hash to point to the resolved hash
    # @return [void]
    def resolve
      @namehash = {}
      @iphash.each do |host, peers|
        host = DNS.getname host
        @namehash[host] = []
        peers.each do |peer|
          @namehash[host].push DNS.getname(peer)
        end
      end
      @hash = @namehash
    end

    # remove peers not matchin configured CIDR
    def clean
      @hash.each do |host, peers|
        peers = peers.delete_if{|peer|not @pollmap.include? peer}
      end
    end

    private

    def initialize hash, pollmap
      @iphash  = hash
      @hash    = @iphash
      @pollmap = pollmap
    end

    def method_missing name, *args
      raise NoMethodError, "invalid method #{name} for #{inspect}:#{self.class}" unless name.match(/to_.*/)
      output = File.basename name[3..-1]
      require_relative 'output/' + output
      output = NetCrawl::Output.const_get output.capitalize
      output.send :output, self
    end
  end
end
