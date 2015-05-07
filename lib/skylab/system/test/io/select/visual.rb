module Skylab::System

  module TestSupport_Visual

    class IO::Select < Client_

      def execute
        @stderr.puts "unpexected argument: #{ @argv.fetch( 0 ).inspect }"
        display_usage
      end

      def when_no_args
        require_relative 'visual-/select.rb'
        NIL_
      end

      def usage_args
        NIL_
      end
    end
  end
end
