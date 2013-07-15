module Skylab::Face

  class FUN_ < ::Module  # buckle up - shit's about to get awesome #yolo

    def stdin
      FUN::Stdin_
    end

    def stdout
      FUN::Stdout_
    end

    def stderr
      FUN::Stderr_
    end

    def program_basename
      @program_basename ||= -> { ::File.basename $PROGRAM_NAME }
    end

    def stylize  # #curriable
      @stylize ||= begin
        up = Face::Services::Headless::CLI::Pen::FUN.stylize
        -> a, s do
          up[ s, *a ]
        end
      end
    end
  end

  FUN = FUN_.new

  module FUN
    Stdin_  = -> { $stdin  }      # (these is slogging their way upwards)
    Stdout_ = -> { $stdout }
    Stderr_ = -> { $stderr }
    At_ = -> *i_a { i_a.map { |i| send i } }
    define_singleton_method :at, & At_
  end
end
