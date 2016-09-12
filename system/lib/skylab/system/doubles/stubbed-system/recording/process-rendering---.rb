module Skylab::System

  class Doubles::Stubbed_System::Recording

    class ProcessRendering___

      def initialize rendering
        @_did_out_did_err = {}
        @_ = rendering
      end

      def express_any_first_line stem, line
        if line
          __do_express_first_line stem, line
        end
        NIL
      end

      def __do_express_first_line stem, line
        @_.express_blank_line
        @_did_out_did_err[ stem ] = true
        @_.indented_puts "  _#{ stem } = <<-HERE.unindent"
        express_line line
        NIL
      end

      def express_line line
        if BLANK_LINE_RX__ =~ line
          @_.raw_puts line
        else
          @_.indented_puts "    #{ line }"
        end
      end

      def receive_an_end_of_lines
        @_.indented_puts "  HERE"
        NIL
      end

      def close d

        @_.express_blank_line

        did = @_did_out_did_err
        _s = if did[ :out ]
          if did[ :err ]
            "  [ #{ d }, _out, _err ]"
          else
            "  [ #{ d }, _out ]"
          end
        elsif did[ :err ]
          "  [ #{ d }, NOTHING_, _err ]"
        else
          "  [ #{ d } ]"
        end

        @_.indented_puts _s
        @_.indented_puts "end"
        NIL
      end

      # ==

      BLANK_LINE_RX__ = Rendering_::BLANK_LINE_REGEXP

      # ==
    end
  end
end
# #history: abstracted from core
