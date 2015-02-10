Gem::Specification.new do |s|
  s.name              = 'netcrawl'
  s.version           = '0.1.0'
  s.licenses          = %w( Apache-2.0 )
  s.platform          = Gem::Platform::RUBY
  s.authors           = [ 'Saku Ytti' ]
  s.email             = %w( saku@ytti.fi )
  s.homepage          = 'http://github.com/ytti/netcrawl'
  s.summary           = 'lldp/cdp crawler'
  s.description       = 'given snmp community and one node crawls through the network to produce list/dot file'
  s.rubyforge_project = s.name
  s.files             = `git ls-files`.split("\n")
  s.executables       = %w( netcrawl )
  s.require_path      = 'lib'

  s.add_runtime_dependency 'snmp',   '~> 1.2'
  s.add_runtime_dependency 'slop',   '~> 3.5'
  s.add_runtime_dependency 'asetus', '~> 0.2'
end
