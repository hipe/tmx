module Skylab::TreetopTools

  module Parser::InstanceMethods

    include Headless::SubClient::InstanceMethods

    def parse_file pn, opts=nil, &p
      _ia = build_file_input_adapter pn, &p
      parse _ia, opts, &p
    end
  private
    def build_file_input_adapter *a, &p
      opts = if a.last.respond_to? :each_pair
        a.last.dup  # don't modify original
      else
        a << (( _ = { } )) ; _
      end
      opts.key? :entity_noun_stem or
        opts[ :entity_noun_stem ] = entity_noun_stem
      Parser::InputAdapters::File.new self, *a, &p
    end
    def entity_noun_stem
      self.class::ENTITY_NOUN_STEM  # :+#call-down
    end

  public

    def parse_stream io, opts=nil, &p
      _ia = build_stream_input_adapter io, &p
      parse _ia, opts, &p
    end
  private
    def build_stream_input_adapter *a
      Parser::InputAdapters::Stream.new self, *a
    end

  public

    def parse_string whole_string, opts=nil, &p
      _ia = build_string_input_adapter whole_string, &p
      parse _ia, opts, &p
    end
  private
    def build_string_input_adapter *a
      Parser::InputAdapters::String.new self, *a
    end

    # ~

    def parse input_adapter, opts=nil
      @input_adapter = input_adapter # #API
      @parse_time_elapsed_seconds = nil
      begin
        load_grammars_if_necessary
        opts and ( r = absorb_parse_opts!( opts ) or break )
        string = input_adapter.resolve_whole_string or break( r = string )
        p = parser or break( r = p )
        t = ::Time.now
        r_ = p.parse string
        @parse_time_elapsed_seconds = ::Time.now - t
        r = r_ ? parser_result( r_ ) : parser_failure
      end while nil
      r
    end

    def load_grammars_if_necessary  # for the children
    end

    def absorb_parse_opts! opts  # for the children
      opts and fail "implement me: 'absorb_parse_opts!' - #{ opts.keys * ', '}"
      true
    end

    def parser
      @parser ||= build_parser
    end

    def build_parser
      cls = parser_class and cls.new
    end

    def parser_class
      @parser_class ||= load_parser_class  # :+#call-down
    end

    def parser_failure
      _msg = parser_failure_reason
      _msg ||= "Got nil from parser without a reason!"
      error _msg  # :+#call-down
      false
    end

    def parser_failure_reason
      parser.failure_reason
    end

    def parser_result result
      result.tree
    end

    def parse_time_elapsed_seconds
      @parse_time_elapsed_seconds
    end
  end
end
