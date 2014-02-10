module Skylab::Face

  FUN = (( class FUN__ < ::Module

    def three_streams
      self::Three_streams
    end

    def stdin
      self::Stdin
    end

    def stdout
      self::Stdout
    end

    def stderr
      self::Stderr
    end

    def program_basename
      @program_bn_p ||= -> { ::File.basename $PROGRAM_NAME }
    end

    def const_values_at * i_a
      i_a.map { |i| const_get i, false }
    end

    self
  end )).new

  module FUN

    Stdin = -> do
      Lib_::System_IO[].some_stdin_IO
    end

    Stdout = -> do
      Lib_::System_IO[].some_stdout_IO
    end

    Stderr = -> do
      Lib_::System_IO[].some_stderr_IO
    end

    Three_streams = -> do
      [ Stdin[], Stdout[], Stderr[] ]
    end

  end
end
