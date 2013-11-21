module Skylab::Face

  class FUN_ < ::Module

    def stdin
      FUN::Stdin_
    end

    def stdout
      FUN::Stdout_
    end

    def stderr
      FUN::Stderr_
    end

    def three_streams
      FUN::Three_streams_
    end

    def program_basename
      @program_basename ||= -> { ::File.basename $PROGRAM_NAME }
    end
  end

  FUN = FUN_.new

  module FUN
    Stdin_  = -> { $stdin  }      # (these is slogging their way upwards)
    Stdout_ = -> { $stdout }
    Stderr_ = -> { $stderr }
    Three_streams_ = -> { [ Stdin_[], Stdout_[], Stderr_[] ] }
    At__ = -> *i_a { i_a.map { |i| send i } }
    define_singleton_method :at, & At__
  end
end
