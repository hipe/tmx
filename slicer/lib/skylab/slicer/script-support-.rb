module Skylab::Slicer

  module ScriptSupport_

    class Invocation < Common_::SimpleModel

      def describe_by & p
        @describe_by = p
      end

      def stdin= io
        @sin = io
      end

      def stderr= io
        @serr = io
      end

      def ARGV= a
        @argv = a
      end

      attr_writer(
        :batch_cache,
      )

      def initialize
        @batch_cache = nil
        @describe_by = nil
        @filesystem = ::File
        @initial_pwd = ::Dir.pwd
        yield self  # not freezing because mm
      end

      def flush_upstream_

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
        __express_help

      elsif @sin.tty?

        __hack_argv
      else
        @serr.puts "can't have both STDIN and args: #{ @argv[ 0 ] }"
        UNABLE_
      end
    end

    def __express_help

      __express_usage
      __express_description_if_any

      STOP_EARLY_
    end

    def __express_description_if_any

      db_p = @describe_by
      if db_p
        y = _build_prefacing_yeilder "description: ", "  "

        y << nil
        # NOTE - separator line between two sections, only because we
        # know that we have the other section (usage) above us. #here-1. etc/meh

        db_p[ y ]
      end
      NIL
    end

    def __express_usage  # depended on by #here-1

      y = _build_prefacing_yeilder "usage: "

      y << "express input items thru either ARGV OR STDIN."
      y << "if neither is present, #{ _FILENAME } will be used."
      NIL
    end

    def _build_prefacing_yeilder preface, margin=nil

      p = nil
      main = -> s do
        if s
          s = "#{ margin }#{ s }"
        end
        @serr.puts s
      end

      transition = -> s do
        margin ||= ( ' ' * preface.length )
        ( p = main )[ s ]
      end

      p = -> s do
        if s
          p = transition
          @serr.puts "#{ preface }#{ s }"
        else
          @serr.puts s
        end
      end

      ::Enumerator::Yielder.new do |s|
        p[ s ]
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
        @___filename ||= ::File.join @initial_pwd, 'REDLIST'
    end

      # --

      def script_path_ k

        @__did_check_this_one_thing ||= __check_this_one_thing

        cache = @_script_path_cache
        cache.fetch k do
          x = __build_script_path k
          cache[ k ] = x
          x
        end
      end

      def __build_script_path k

        _tail = case k
        when :_essentials_script_     ; "083-install-essential-gems"
        when :_reallocate_sigils_     ; "250-reallocate-sigils"
        else ; no
        end

        ::File.join( @__script_head, _tail ).freeze
      end

      def __check_this_one_thing

        head = ::File.join ".", "slicer", "script"
        @filesystem.exist? head or sanity
        @__script_head = head
        @_script_path_cache = {}
        true
      end

      # --

      def stderr
        @serr
      end

      attr_reader(
        :batch_cache,
        :filesystem,
        :initial_pwd,
      )
    end

    # -

    # ==

    DASH_ = '-'
    STOP_EARLY_ = nil

    # ==
    # ==
  end
end
