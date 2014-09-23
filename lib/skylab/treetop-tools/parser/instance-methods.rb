module Skylab::TreetopTools

  module Parser::InstanceMethods  # you must implement the #call-down's below

    Lib_::Event[].sender self

    def parse_file pn, *a, &p
      _ia = build_file_input_adapter pn, &p
      parse _ia, a, p
    end

  private

    def build_file_input_adapter *a, &p
      opts = if a.last.respond_to? :each_pair
        a.last.dup  # don't modify original
      else
        a << (( _ = {} )) ; _  # NOT 'EMPTY_H_' (it will get mutated)
      end
      opts.key? :entity_noun_stem or
        opts[ :entity_noun_stem ] = entity_noun_stem
      Parser::InputAdapters::File.new self, *a, &p
    end

    def entity_noun_stem
      'input'
    end

  public

    def parse_stream io, *a, &p
      _ia = build_stream_input_adapter io, &p
      parse _ia, a, p
    end

    private def build_stream_input_adapter *a
      Parser::InputAdapters::Stream.new self, *a
    end

    def parse_string whole_string, *a, &p
      _ia = build_string_input_adapter whole_string, &p
      parse _ia, a, p
    end

  private

    def build_string_input_adapter *a
      Parser::InputAdapters::String.new self, *a
    end

    def parse input_adapter, a, p
      @input_adapter = input_adapter  # :#API
      @parse_time_elapsed_seconds = nil
      p and self._TEST_ME
      load_grammars_if_necessary
      ok = true
      a.length.nonzero? and ok = absorb_parse_opts!( * a )
      ok &&= resolve_whole_string
      ok &&= resolve_parser
      ok and begin
        t = ::Time.now
        x = @parser.parse @whole_string
        @parse_time_elapsed_seconds = ::Time.now - t
        if x
          parser_result x
        else
          when_parse_failure
        end
      end
    end

    def load_grammars_if_necessary  # for the children
    end

    def absorb_parse_opts! opts  # for the children
      opts and fail "implement me: 'absorb_parse_opts!' - #{ opts.keys * ', '}"
      PROCEDE_
    end

    def resolve_whole_string
      @whole_string = @input_adapter.resolve_whole_string
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
      @parser_class ||= load_parser_class  # :+#call-down
    end

    def when_parse_failure
      _ev = build_parse_failure_event
      receive_parse_failure_event _ev  # :+#call-down
      UNABLE_
    end

    def build_parse_failure_event
      msg = parser_failure_reason
      msg ||= "Got nil from parser without a reason!"
      build_error_event_with :parse_failed, :reason, msg do |y, o|
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
