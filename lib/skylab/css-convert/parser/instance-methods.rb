module Skylab::CssConvert
  module Parser::InstanceMethods
    Parser = CssConvert::Parser
    include My::Headless::SubClient::InstanceMethods
    def build_file_input_adapter *a
      a.last.kind_of?(::Hash) or a.push({})
      a.last.key?(:entity) or a.last[:entity] = entity
      Parser::InputAdapters::File.new(request_runtime, *a)
    end
    def build_stream_input_adapter *a
      Parser::InputAdapters::Stream.new(request_runtime, *a)
    end
    def build_string_input_adapter *a
      CssConvert::Parser::InputAdapters::String.new(request_runtime, *a)
    end
    def build_parser
      parser_class.new
    end
    def entity
      self.class.const_get(:ENTITY_NOUN_STEM)
    end
    def parse_file pn
      parse build_file_input_adapter(pn)
    end
    def parse_stream io
      parse build_stream_input_adapter(io)
    end
    def parse_string whole_string
      parse build_string_input_adapter(whole_string)
    end
    def parse input_adapter
      whole_string = input_adapter.resolve_whole_string or return whole_string
      result = parser.parse(whole_string)
      result or emit(:error,
        (parser.failure_reason || "Got nil from parse without reason!"))
      result ? result.tree : result
    end
    def parser
      @parser ||= build_parser
    end
  end
end
