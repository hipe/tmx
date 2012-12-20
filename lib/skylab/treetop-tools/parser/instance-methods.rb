require 'skylab/headless/core'

module Skylab::TreetopTools
  module Parser::InstanceMethods
    include Headless::SubClient::InstanceMethods

    def parse_file pn, o=nil, &b
      r = nil
      begin
        a = build_file_input_adapter pn, &b
        r = parse a, o, &b
      end while nil
      r
    end

    def parse_stream io, o=nil, &b
      r = nil
      begin
        a = build_stream_input_adapter io, &b
        r = parse a, o, &b
      end while nil
      r
    end

    def parse_string whole_string, o=nil, &b
      r = nil
      begin
        a = build_string_input_adapter whole_string, &b
        r = parse a, o, &b
      end while nil
      r
    end

  protected

    def absorb_parse_opts! opts   # for the children
      true
    end

    def build_file_input_adapter *a, &b
      if ::Hash === a.last
        opts = a.last.dup         # don't modify original object
      else
        opts = { }
        a.push opts               # hacklette for when we pass `a` on below
      end
      if ! opts.key? :entity_noun_stem
        opts[:entity_noun_stem] = entity_noun_stem
      end
      Parser::InputAdapters::File.new self, *a, &b
    end

    def build_stream_input_adapter *a
      Parser::InputAdapters::Stream.new self, *a
    end

    def build_string_input_adapter *a
      Parser::InputAdapters::String.new self, *a
    end

    def build_parser
      klass = parser_class and klass.new
    end

    def entity_noun_stem
      self.class::ENTITY_NOUN_STEM # not const_get(.., false)
    end

    attr_reader :input_adapter

    def parse input_adapter, o=nil
      result = nil
      begin
        if o
          result = absorb_parse_opts! o
          result or break
        end
        @parse_time_elapsed_seconds = nil
        @input_adapter = input_adapter
        string = input_adapter.resolve_whole_string or break
        parser = self.parser or break
        t1 = ::Time.now
        r = parser.parse string
        @parse_time_elapsed_seconds = ::Time.now - t1
        if r
          result = parser_result r
        else
          result = parser_failure
        end
      end while nil
      result
    end

    def parser
      @parser ||= build_parser
    end

    def parser_class
      @parser_class ||= load_parser_class
    end

    def parser_failure
      error(parser_failure_reason || 'Got nil from parser without a reason!')
      false
    end

    def parser_failure_reason
      parser.failure_reason
    end

    def parser_result result
      result.tree
    end

    attr_reader :parse_time_elapsed_seconds
  end
end
