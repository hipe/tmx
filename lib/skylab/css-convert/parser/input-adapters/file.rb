module Skylab::CssConvert
  class Parser::InputAdapters::File < Parser::InputAdapters::Stream
    def entity
      (@entity ||= nil) || 'input file'
    end
    attr_writer :entity
    def resolve_whole_string
      if upstream.respond_to?(:pretty)
        @state = :pathname
      end
      if :initial == state
        ::String === upstream or fail("expecting pathname string, had #{upstream.class}")
        self.upstream = CssConvert::MyPathname.new(upstream)
        @state = :pathname
      end
      if :pathname == state
        upstream.exist? or return error("#{entity} not found: #{upstream.pretty}")
        upstream.directory? and return error("expecing #{entity}, had directory: #{upstream.pretty}")
        self.upstream = upstream.open('r')
        self.state = :open
      end
      super
    end
  end
end
