# Netcrawl
Given snmp community and single device, crawls the network via discovering
LLDP/CDP neighbours, while producing list or dot file (for graphviz digraphs)

## Install
% gem install netcrawl

## Use
% netcrawl --graphiz router.example.com

## Command line
```
Usage: netcrawl [options] hostname
    -g, --graphviz       dot output use 'dot -Tpng -o map.png map.dot'
    -l, --list           list nodes
    -j, --json           json output
    -y, --yaml           yaml output
    -a, --hash           hash/associative array output
    -r, --resolve        resolve addresses to names
    -p, --purge          remove peers not in configured CIDR
    -c, --community      SNMP community to use
    -d, --debug          turn debugging on
    -h, --help           Display this help message.

```
  * graphiz   - graphis (dot) output
  * list      - list nodes found
  * json      - json output
  * yaml      - yaml output
  * hash      - ruby hash output
  * resolve   - resolve IP addresses
  * purge     - remove non-cidr matching peers from output
  * community - sets snmp community
  * debug     - turn on debugging

## Config
```
---
use:
- LLDP
- CDP
poll:
- 192.0.2.0/24
snmp:
  community: public
  timeout: 1
  retries: 2
  bulkrows: 35
dot:
  bothlinks: true
  color:
  - - cpe
    - gold
  - - -sw
    - blue
  - - -pe
    - red
  - - ' -p'
    - yellow
dns:
  afi: 
log: STDERR
debug: false
namemap:
- - -re\d+
  - ''
- - (.*(?<!as23456.net)$)
  - \1.as23456.net
```

  * use  - methods to use for crawling
  * poll - cidrs to allow snmp for
  * snmp community - snmp community to use
  * snmp timout    - snmp timout in seconds
  * snmp retries   - snmp retries count
  * snmp bulkrows  - snmp row count for bulkget
  * dot bothlinks  - show a-b and b-a link
  * dot color      - regexp to color, first hit used
  * dns afi        - ipv4/ipv6 or nil
  * log            - STDERR/STDOUT or file
  * debug          - debugging
  * namemap        - map (LLDP) name to FQDN (JunOS does not give domain)

## Library use
require 'netcrawl'
output = NetCrawl.new.crawl('192.0.2.1').to_hash
