require 'skylab/treetop-tools/core'

module Skylab::CssConvert
  module Parser end
  module Parser::Extlib end
  module Parser::Extlib::InstanceMethods # #watched for dry at [#ttt-002]

    def self.override; [:failure_reason] end

    def my_failure_reason
      return nil unless (tf = terminal_failures) && tf.size > 0
      "Expected " +
        ( tf.size == 1 ?
          tf[0].expected_string.inspect :
          "one of #{tf.map{|f| f.expected_string.inspect}.uniq*', '}"
        ) + " at line #{failure_line}, column #{failure_column} " +
        "(byte #{failure_index+1}) #{my_input_excerpt}"
    end

    def num_context_lines ; 4 end

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

  module Parser::InstanceMethods
    include ::Skylab::TreetopTools::Parser::InstanceMethods # sub-client
    def load_parser_class_with &dsl
      events = -> o do
        o.on_info { |e| call_digraph_listeners :info, "#{ em '*' } #{ e }" }
        # o.on_error { |e| error "failed to load grammar: #{ e }" }
        o.on_error { |e| fail "failed to load grammarz: #{ e }" }
      end
      p = ::Skylab::TreetopTools::Parser::Load.new self, dsl, events
      p.invoke
    end
  end

  class Parser::Sexpesque < ::Array
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
