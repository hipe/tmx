module Skylab::CSS_Convert

  Parser_ = ::Module.new

  module Parser_::Parser_Instance_Methods  # #watched for dry at [#ttt-002]

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

    def initialize out_dir_head, resources, & oes_p

      @on_event_selectively = oes_p
      @out_dir_head = out_dir_head
      @resources = resources
    end

    def parse_path path

      o = _start_parse_via_path path
      if o
        o.flush_to_parse_tree
      else
        o
      end
    end

    def syntax_node_via_path path
      o = _start_parse_via_path path
      if o
        o.flush_to_syntax_node
      else
        o
      end
    end

    def _start_parse_via_path path
      o = _start_parse
      if o
        o.accept_upstream_path path
      end
      o
    end

    def _start_parse

      cls = produce_parser_class
      if cls
        o = Home_.lib_.treetop_tools::Sessions::Parse.new( & @on_event_selectively )
        o.accept_parser_class cls
        o
      else
        cls
      end
    end

    def start_treetop_require_

      Home_.lib_.treetop_tools::Sessions::Require.new do | * i_a, & ev_p |

        if :error == i_a.first
          raise ev_p[].to_exception
        else
          @on_event_selectively.call( * i_a, & ev_p )
        end
      end
    end
  end

  Parser_::Models = ::Module.new

  class Parser_::Models::Sexpesque < ::Array

    alias_method :node_name, :first

    class << self

      def build name, *childs
        childs.unshift name
        new childs
      end

      alias_method :[], :build

      private :new
    end  # >>

    alias_method :fetch, :[]

    def [] mixed
      mixed.kind_of?(::Symbol) ? super(1)[mixed] : super(mixed)
    end

    def children sym, *syms
      ([sym] + syms).map { |x| fetch(1)[x] }
    end
  end
end
