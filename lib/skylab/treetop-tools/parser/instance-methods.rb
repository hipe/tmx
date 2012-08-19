require 'skylab/headless/core'

module Skylab::TreetopTools
  module Parser::InstanceMethods
    include Headless::SubClient::InstanceMethods
    def parse_file pn, &b
      parse(build_file_input_adapter(pn, &b), &b)
    end
    def parse_stream io, &b
      parse(build_stream_input_adapter(io, &b), &b)
    end
    def parse_string whole_string, &b
      parse( build_string_input_adapter(whole_string, &b), &b)
    end
  protected
    def build_file_input_adapter *a, &b
      a.last.kind_of?(::Hash) or a.push({})
      a.last.key?(:entity) or a.last[:entity] = entity_noun_stem
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
    def entity_noun_stem
      self.class.const_get(:ENTITY_NOUN_STEM)
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
