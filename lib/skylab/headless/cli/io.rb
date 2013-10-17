module Skylab::Headless

  module CLI

    class IO_ < ::Module

      def stdin  # #todo - these should be renamed to "*_proc" or changed so that they do not result in procs but IO's
        IO::Stdin_
      end

      def stdout
        IO::Stdout_
      end

      def stderr
        IO::Stderr_
      end

      def three_streams
        IO::Three_streams_
      end
    end

    IO = IO_.new
    module IO
      Stdin_  = -> { $stdin  }
      Stdout_ = -> { $stdout }
      Stderr_ = -> { $stderr }
      Three_streams_ = -> { [ Stdin_[], Stdout_[], Stderr_[] ] }
    end
  end
end
