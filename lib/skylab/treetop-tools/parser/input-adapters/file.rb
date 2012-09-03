module Skylab::TreetopTools
  class Parser::InputAdapters::File < Parser::InputAdapters::Stream
    def entity
      (@entity ||= nil) || 'input file'
    end
    attr_writer :entity
    attr_reader :pathname
    def resolve_whole_string
      # If necessary, turn the 'upstream' from a pathspec (String or Pathname)
      # into an open stream (setting @pathname), and emit errors if not.

      if :initial == state
        # normalize pathname based on whether it is a a string, a customized
        # pathname, or a ::Pathname.  (sorry this is a bit ugly/cautious now.)
        @pathname =
          if upstream.respond_to?(:pretty)
            upstream
          elsif ::Pathname === upstream
            Pathname.new(upstream.to_s) # !
          elsif ::String === upstream
            Pathname.new(upstream) # !
          else
            fail("expecting pathname string, had #{upstream.class}")
          end
        self.upstream = nil
        self.state = :pathname
      end
      if :pathname == state
        pathname.exist? or return file_not_found
        pathname.directory? and return file_is_dir
        self.upstream = pathname.open('r')
        self.state = :open
      end
      super # or we might later decide to handle broken pipes here
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
      end).call(pathname, entity)
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
