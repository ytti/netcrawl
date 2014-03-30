require 'asetus'
require 'logger'
class NetCrawl
  Config = Asetus.new :name=>'netcrawl', :load=>false
  Config.default.use             = %w(LLDP CDP)
  Config.default.poll            = [  # addresses accepted for polling
    '192.0.2.0/24',
    '198.51.100.0/24',
    '0.0.0.0/0',
  ]
  Config.default.snmp.community  = 'public'
  Config.default.snmp.timeout    = 1
  Config.default.snmp.retries    = 2
  Config.default.snmp.bulkrows   = 35    # 1500B packet should fit about 50 :cdpCacheAddress rows
  Config.default.dot.bothlinks   = false # keep both a-b and b-a links
  Config.default.dot.color       = [     # regexp of host => color
    [ 'cpe', 'gold'   ],
    [ '-sw', 'blue'   ],
    [ '-pe', 'red'    ],
    [' -p',  'yellow' ],
  ]
  Config.default.dns.afi         = nil # could be 'ipv4' or 'ipv6'
  Config.default.log             = 'STDERR'
  Config.default.debug           = false
  Config.default.namemap         = [ # regexp match+sub of hostname (needed for LLDP)
    ['-re\d+', ''],
    ['^KILLME(.*(?<!my.domain.com)$)', '\1.my.domain.com'],  #adds missing domain name
  ]
  Config.load
  CFG = Config.cfg
  log = CFG.log
  log = STDERR if log == 'STDERR'
  log = STDOUT if log == 'STDOUT'
  Log = Logger.new log
  Log.level = Logger::INFO
  Log.level = Logger::DEBUG if CFG.debug
end
