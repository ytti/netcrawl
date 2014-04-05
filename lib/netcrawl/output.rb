class NetCrawl
  class Output
    attr_reader :peers, :resolve

    # @return [String] pretty print of hash
    def to_hash
      require 'pp'
      out = ''
      PP.pp to_h, out
      out
    end

    # @return [String] yaml of hosts and peers found
    def to_yaml
      require 'yaml'
      YAML.dump to_h
    end

    # @return [String] json of hosts and peers found
    def to_json
      require 'json'
      JSON.pretty_generate to_h
    end

    # @return [Array] of nodes found
    def to_list
      nodes = []
      @peers.each do |host, peers|
        nodes << host
        peers.each do |peer|
          nodes.push @resolve ? peer.name : peer.ip
        end
      end
      nodes.flatten.uniq.sort
    end

    # resolves ip addresses of peers and @peers keys
    # @return [void]
    def resolve!
      @resolve = true
      newpeers = {}
      @peers.each do |host, peers|
        peers.each { |peer| peer.name }
        name = DNS.getname host
        newpeers[name] = peers
      end
      @peers = newpeers
    end

    # remove peers not matching to configured CIDR
    # @return [void]
    def clean!
      @peers.each do |host, peers|
        peers.delete_if{|peer|not @pollmap.include? peer.ip}
      end
    end

    private

    def initialize peers, pollmap
      @peers   = peers
      @pollmap = pollmap
      @resolve = false
    end

    def method_missing name, *args
      raise NoMethodError, "invalid method #{name} for #{inspect}:#{self.class}" unless name.match(/to_.*/)
      output = File.basename name[3..-1]
      require_relative 'output/' + output
      output = NetCrawl::Output.const_get output.capitalize
      output.send :output, self
    end

    def to_h
      hash = {}
      @peers.each do |host, peers|
        ary = []
        peers.each do |peer|
          ary << peer.to_hash
        end
        hash[host] = ary
      end
      hash
    end
  end
end
