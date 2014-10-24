require 'skylab/treetop-tools/core'

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

  module Parser_::InstanceMethods

    include ::Skylab::TreetopTools::Parser::InstanceMethods

    def initialize mode_client
      @actuals = mode_client.actual_parameters
      @delegate = mode_client
      @expag = mode_client.expression_agent
    end

    def load_parser_class_with & _DSL
      p = ::Skylab::TreetopTools::Parser::Load.new self, _DSL, -> o do
        o.on_info handle_info_event
        o.on_error handle_error
      end
      p.invoke
    end

  private

    def actual_parameters
      @actuals
    end

    def handle_info_event
      -> ev do
        _msg = @expag.calculate do
          ev.render_all_lines_into_under y=[], self
          "#{ em '*' } #{ y * SPACE_ }"
        end
        send_info_message _msg
      end
    end

    def handle_error
      -> ev do
        _e = if ev.respond_to? :to_exception
          ev.to_exception
        else
          ::RuntimeError.new "failed to load grammarz: #{ ev }"
        end
        raise _e
      end
    end

    def parameter_label param, d=nil  # while subclient
      d and _tail = "[#{ d }]"
      "«#{ param.name.as_method }#{ _tail }»"  # :+#guillemets
    end

    include Event_Sender_Methods_

    def send_string_on_channel s, i
      @delegate.receive_string_on_channel s, i
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
