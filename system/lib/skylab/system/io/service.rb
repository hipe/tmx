module Skylab::System
  # -
    class IO::Service

      def initialize _services
      end

      def some_two_IOs
        [ some_stdout_IO, some_stderr_IO ]
      end

      def some_three_IOs
        [ some_stdin_IO, some_stdout_IO, some_stderr_IO ]
      end

      -> do  # there are two OCD reasons we don't just use the consts or globals

        _STDIN = $stdin
        define_method :some_stdin_IO do
          _STDIN_
        end

        _STDOUT = $stdout
        define_method :some_stdout_IO do
          _STDOUT
        end

        _STDERR = $stderr
        define_method :some_stderr_IO do
          _STDERR
        end

      end.call
    end
  # -
end
