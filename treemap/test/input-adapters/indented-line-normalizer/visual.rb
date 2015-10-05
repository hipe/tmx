module Skylab::Treemap

  module TestSupport_Visual

    class Input_Adapters::Indented_Line_Normalizer< Client_

      def usage_args
        NIL_
      end

      def execute
        @stderr.puts "unexpected argument: #{ @argv.first.inspect }"
        display_usage
      end

      def when_no_args
        if @stdin.tty?
          @stderr.puts "(takes non-interactive stdin only - pipe something to it)"
        else
          __go
        end
      end

      def __go

        begin
          x = @stdin.gets
          if x
            @stderr.puts "K: #{ x.inspect }"
            redo
          else
            @stderr.puts "goodbye!"
            break
          end
        end while nil
        NIL_
      end
    end
  end
end
