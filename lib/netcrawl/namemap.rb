class NetCrawl
  module NameMap
    def namemap name_org
      name = name_org.dup
      CFG.namemap.each do |match, replace|
        re = Regexp.new match
        name = name.sub re, replace
      end
      name
    end
  end
end
