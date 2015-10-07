require 'skylab/brazen'

module Skylab::Slicer

  class Script_Support_

    # (this again)

    class << self

      def resolve_upstream sin, serr, argv

        new( sin, nil, serr, argv ).__resolve_upstream
      end
    end

    def initialize sin, _, serr, argv
      @sin = sin ; @serr = serr; @argv = argv
    end

    def __resolve_upstream

      if @argv.length.zero?
        __no_argv
      else
        __argv
      end
    end

    def __no_argv

      if @sin.tty?
        __read_file
      else
        @sin
      end
    end

    def __read_file
      ::File.open _FILENAME, ::File::RDONLY
    end

    def __argv

      if DASH_ == @argv[ 0 ][ 0 ] || DASH_ == @argv[ -1 ][ 0 ]
        @serr.puts "usage: express input items thru either ARGV OR STDIN."
        @serr.puts "       if neither is present, #{ _FILENAME } will be used."
        NIL_

      elsif @sin.tty?

        __hack_argv
      else
        @serr.puts "can't have both STDIN and args: #{ @argv[ 0 ] }"
        UNABLE_
      end
    end

    def __hack_argv

      argv = @argv
      upstream = -> do
        s = argv.shift
        if s
          s = "#{ s }\n"  # argv strings are frozen
        end
        s
      end
      upstream.singleton_class.send :alias_method, :gets, :call
      upstream
    end

    def _FILENAME
      @___filename ||= ::File.join( ::Dir.pwd, 'REDLIST' )
    end

    DASH_ = '-'
  end
end
