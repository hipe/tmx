module Skylab::CSS_Convert

  Parser_ = ::Module.new

  Parser_::Extlib = ::Module.new

  module Parser_::Extlib::InstanceMethods  # #watched for dry at [#ttt-002]

    def self.override
      [ :failure_reason ]
    end

    def my_failure_reason
      return nil unless (tf = terminal_failures) && tf.size > 0
      "Expected " +
        ( tf.size == 1 ?
          tf[0].expected_string.inspect :
          "one of #{tf.map{|f| f.expected_string.inspect}.uniq*', '}"
        ) + " at line #{failure_line}, column #{failure_column} " +
        "(byte #{failure_index+1}) #{my_input_excerpt}"
    end

    def num_context_lines
      4
    end

    def my_input_excerpt
      0 == failure_index and return "at:\n1: #{input.match(/.*/)[0]}"
      all = input[index...failure_index].split("\n", -1)
      lines = all.slice(-1 * [all.size, num_context_lines].min, all.size)
      nos = failure_line.downto(
        [1, failure_line - num_context_lines + 1].max).to_a.reverse
      w = nos.last.to_s.size # width of greatest line number as string
      "after:\n" <<
        (nos.zip(lines).map{|no, s| ("%#{w}i" % no) + ": #{s}" } * "\n")
    end
  end

  class Parser_::Common_Base

    def initialize mode_client
      @actuals = mode_client.actual_parameters
      @delegate = mode_client
      @expag = mode_client.expression_agent
    end

    def parse_path path

      o = LIB_.treetop_tools.new_parse
      o.receive_upstream_path path
      o.receive_parser_class produce_parser_class
      o.flush_to_parse_tree
    end

    def load_parser_class_with__ & _DSL

      _load = LIB_.treetop_tools::Load.new _DSL do | o |
        o.on_info __handle_info
        o.on_error __handle_error
      end
      _load.execute
    end

    def __handle_info
      -> ev do
        @delegate.receive_event_on_channel__ ev, :info
      end
    end

    def __handle_error
      -> * do
        self._DO_ME
      end
    end
  end

  class Parser_::Sexpesque < ::Array

    alias_method :node_name, :first

    class << self
      def build name, *childs
        new([name, *childs])
      end
      alias_method :[], :build
    end

    alias_method :fetch, :[]

    def [] mixed
      mixed.kind_of?(::Symbol) ? super(1)[mixed] : super(mixed)
    end

    def children sym, *syms
      ([sym] + syms).map { |x| fetch(1)[x] }
    end
  end
end
