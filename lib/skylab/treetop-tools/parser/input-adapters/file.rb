module Skylab::TreetopTools

  class Parser::InputAdapters::File < Parser::InputAdapters::Stream

    def default_entity_noun_stem
      'input file'
    end

    attr_reader :pathname

    def resolve_whole_string

      if :initial == state        # if necessary, turn the `upstream` from a
        case upstream             # "pathspec" (::String or ::Pathname) into
        when ::String             # an open stream (!) setting @pathname, and
          pn = ::Pathname.new upstream.to_s # emit appropriate errors if we
        when ::Pathname           # cannot open the file.  This moves our state
          pn = upstream           # from :initial to :pathname
        else
          fail "expecting pathname string or pathmame, had #{ upstream.class }"
        end
        @pathname = pn
        self.upstream = nil
        self.state = :pathname
      end

      res = -> do                 # move our state forward from :pathname
        if :pathname == state     # to :open, dealing with errors that might
          if ! pathname.exist?    # occur ([#hl-022] pattern, watch for dry)
            break file_not_found
          end
          if pathname.directory?
            break file_is_dir
          end
          self.upstream = pathname.open 'r'
          self.state = :open
        end
        super # or we might later decide to handle broken pipes here
      end.call
      res
    end

    def type
      Parser::InputAdapter::Types::FILE
    end

  protected

    EVENTS = Headless::Parameter::Definer.new do
      param :on_file_is_dir,    hook: true, writer: true
      param :on_file_not_found, hook: true, writer: true
    end

    def events
      @events ||= begin
        block = self.block
        block ||= ->(p) do
          p.on_file_is_dir    { |e| fail("file is dir: #{pathname}") }
          p.on_file_not_found { |e| fail("file not found: #{pathname}") }
        end
        EVENTS.new(&block)
      end
    end

    def file_is_dir
      (events.on_file_is_dir || ->(pathname, entity) do
        error("expecting #{entity}, had directory: #{upstream.pretty}")
      end).call(pathname, entity_noun_stem)
      nil
    end

    def file_not_found
      f = events.on_file_not_found
      f ||= -> pathname, entity do
        error "#{ entity } not found: #{ pathname.pretty }"
      end
      f[ pathname, entity_noun_stem ]
      nil
    end
  end
end
