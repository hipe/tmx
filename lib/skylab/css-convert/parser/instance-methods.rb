module Skylab::CssConvert
  module Parser::InstanceMethods
    Parser = CssConvert::Parser
    include My::Headless::SubClient::InstanceMethods
    def build_file_input_adapter *a, &b
      a.last.kind_of?(::Hash) or a.push({})
      a.last.key?(:entity) or a.last[:entity] = entity
      Parser::InputAdapters::File.new(request_runtime, *a, &b)
    end
    def build_stream_input_adapter *a
      Parser::InputAdapters::Stream.new(request_runtime, *a)
    end
    def build_string_input_adapter *a
      Parser::InputAdapters::String.new(request_runtime, *a)
    end
    def build_parser
      klass = parser_class and klass.new
    end
    def entity
      self.class.const_get(:ENTITY_NOUN_STEM)
    end
    def load_parser_class &dsl_f
      _events_f = ->(o) do
        o.on_info { |e| emit(:info, "#{em '*'} #{e}") }
        # o.on_error { |e| error("failed to load grammar: #{e}") }
        o.on_error { |e| fail("failed to load grammarz: #{e}") }
      end
      CssConvert::TreetopTools::Parser::Load.new(dsl_f, _events_f).invoke
    end
    def parse_file pn, &b
      parse(build_file_input_adapter(pn, &b), &b)
    end
    def parse_stream io, &b
      parse(build_stream_input_adapter(io, &b), &b)
    end
    def parse_string whole_string, &b
      parse( build_string_input_adapter(whole_string, &b), &b)
    end
    def parse input_adapter
      s = input_adapter.resolve_whole_string and
      p = parser and
      result = p.parse(s) and
      (result.tree or (error(
        p.failure_reason || "Got nil from parser without a reason!") && false))
    end
    def parser
      @parser ||= build_parser
    end
    def parser_class
      @parser_class ||= load_parser_class
    end
  end
end
