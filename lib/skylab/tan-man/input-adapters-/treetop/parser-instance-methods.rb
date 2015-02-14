module Skylab::TanMan

  module Input_Adapters_::Treetop

  module Parser_Instance_Methods  # you must implement the #hook-out's below

    Callback_::Event.selective_builder_sender_receiver self

    def parse_file path, & oes_p
      _ia = build_file_input_adapter path, & oes_p
      parse _ia, EMPTY_A_, & oes_p
    end

  private

    def build_file_input_adapter path, & oes_p

      TanMan_.lib_.system.filesystem.class::Byte_Upstream_Identifier.
        new( path, & oes_p )

    end

    def entity_noun_stem  # :+#public-API #hook-in
      'input'
    end

  public

    def parse_string whole_string, *a, & oes_p
      _ia = build_string_input_adapter whole_string, & oes_p
      parse _ia, a, & oes_p
    end

  private

    def build_string_input_adapter s, & x_p
      TanMan_.lib_.basic::String::Byte_Upstream_Identifier.new s, & x_p
    end

    def parse input_adapter, a, & oes_p
      @input_adapter = input_adapter  # :#API
      @parse_time_elapsed_seconds = nil
      load_grammars_if_necessary
      ok = true
      a.length.nonzero? and ok = absorb_parse_opts!( * a )
      ok &&= rslv_whole_string
      ok &&= resolve_parser
      ok and begin
        t = ::Time.now
        x = @parser.parse @whole_string
        @parse_time_elapsed_seconds = ::Time.now - t
        if x
          parser_result x
        else
          when_parse_failure( & oes_p )
        end
      end
    end

    def load_grammars_if_necessary  # for the children
    end

    def absorb_parse_opts! opts  # for the children
      opts and fail "implement me: 'absorb_parse_opts!' - #{ opts.keys * ', '}"
      PROCEDE_
    end

    def rslv_whole_string
      @whole_string = @input_adapter.whole_string
      @whole_string ? PROCEDE_ : @whole_string
    end

    def resolve_parser
      parser
      @parser ? PROCEDE_ : @parser
    end

    def parser
      @parser ||= build_parser
    end

    def build_parser
      cls = parser_class and cls.new
    end

    def parser_class
      @parser_class ||= produce_parser_class  # :+#hook-out
    end

    def when_parse_failure & oes_p
      if oes_p
        oes_p.call :error, :parse_failed do
          build_parse_failure_event
        end
      else
        receive_parse_failure_event build_parser  # :+#hook-out
      end
      UNABLE_
    end

    def build_parse_failure_event  # :+#public-API #hook-in
      msg = parser_failure_reason
      msg ||= "Got nil from parser without a reason!"
      build_not_OK_event_with :parse_failed, :reason, msg do |y, o|
        y << o.msg
      end
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
end