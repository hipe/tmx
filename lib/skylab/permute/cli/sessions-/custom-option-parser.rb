module Skylab::Permute

  class CLI

    class Sessions_::Custom_Option_Parser

      def initialize & x_p

        @mutate_syntax_string_parts = nil

        @__receive_help = -> a, p do
          @help_pair = [ a, p ]
          @__receive_help = nil
        end

        @_oes_p = x_p
      end

      attr_reader :help_pair

      def on * a, & p
        LONG_HELP__ == a[ 1 ] or self._SANITY
        @__receive_help[ a, p ]
        NIL_
      end

      def summary_indent
        '  '
      end

      def summary_width
        2
      end

      def parse! argv  # we've gotta follow stdlib o.p API

        sess = Sessions_::Custom_Parse_Session.new( & @_oes_p )

        sess.long_help_switch = LONG_HELP__
        sess.short_help_switch = SHORT_HELP___
        sess.do_mutate_argument_array = true
        sess.argument_array = argv
        ok_x = sess.execute
        if ok_x
          @_oes_p.call :payload, :array, :parsed_nodes do
            ok_x
          end
        end
        NIL_
      end

      LONG_HELP__ = '--help' ; SHORT_HELP___  = '-h'

      def main_syntax_string_parts

        s_a = [ '--your-category YOUR-VALUE',
          '[ -y VALUE2 [ -y VAL3 [..]]]',
          '--other-cat VAL',
          '[ -o V2 [ -o V3 [..]]]' ]

        if @mutate_syntax_string_parts
          @mutate_syntax_string_parts[ s_a ]
        end

        s_a
      end

      attr_writer :mutate_syntax_string_parts

      # ~ begin mock another object with same class

      def top
        self
      end

      def list
        EMPTY_A_
      end

      # ~ end

      def summarize y

        y << "[ \"options\" are a wide-open namespace for your categories ]"

      end
    end
  end
end
