module Skylab::TreetopTools
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
        ::String === upstream or
          fail("expecting pathname string, had #{upstream.class}")
        self.upstream = Pathname.new(upstream) # !
        @state = :pathname
      end
      if :pathname == state
        upstream.exist? or return file_not_found
        upstream.directory? and file_id_dir
        self.upstream = upstream.open('r')
        self.state = :open
      end
      super
    end
  protected
    EVENTS = Headless::Parameter::Definer.new do
      param :on_file_is_dir,    hook: true, writer: true
      param :on_file_not_found, hook: true, writer: true
    end
    def events
      @events ||= EVENTS.new(&block)
    end
    def file_is_dir
      (events.on_file_is_dir || ->(pathname, entity) do
        error("expecting #{entity}, had directory: #{upstream.pretty}")
      end).call(upstream, entity)
      nil
    end
    def file_not_found
      (events.on_file_not_found || ->(pathname, entity) do
        error("#{entity} not found: #{pathname.pretty}")
      end).call(upstream, entity)
      nil
    end
  end
end
