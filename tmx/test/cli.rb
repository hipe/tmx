module Skylab::TMX::TestSupport

  module CLI

    def self.[] tcc

      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___
    end

    module ModuleMethods___

      def given_test_directories s_a
        define_method :prepare_CLI do |cli|
          _st = TS_::Operations::Map::Dir01::JSON_file_stream_via[ s_a ]
          cli.json_file_stream_by { _st } ; nil
        end
      end

      def given & p
        x = nil ; yes = true
        define_method :the_givens do
          if yes
            yes = false
            @the_givens = Givens___.new
            instance_exec( & p )
            x = remove_instance_variable :@the_givens
            x
          else
            For_now_fail_with_this_message___[]
          end
        end
      end
    end

    # ==

    For_now_fail_with_this_message___ = -> do
      fail "needs consideration - etc"
    end

    Givens___ = ::Struct.new :argv

    # ==

    module InstanceMethods___

      # -- setup

      def finish_with_common_machine_
        mach = CommonMachine___.new
        expect_each_on_stderr_by( & mach.method( :receive_line ) )
        expect_failed
        mach.finish
      end

      def will_invoke_via_argv argv
        @the_givens.argv = argv ; nil
      end

      def invoke_it
        _argv = the_givens.argv
        invoke_via_argv _argv
        NIL
      end

      # -- setup structures for assertion

      def expect_common_help_screen_sections_by_

        sct = HelpScreenCommonFourSections___.new

        o = Zerk_lib_[].test_support::CLI::Expect_Section_Fail_Early.define

        yield sct, o

        spy = o.finish.to_spy_under self
        io = spy.spying_IO
        expect_each_on_stderr_by do |line|
          io.puts line
          NIL  # keep parsing
        end
        expect_succeeded  # big money

        spy.finish

        sct
      end

      # -- assert

      def expect_failed_normally_
        expect "try 'tmz -h'"
        expect_failed
      end

      # --

      def prepare_CLI cli
        NOTHING_
      end

      define_method :program_name_string_array, ( Lazy_.call do
        %w( tmz )
      end )

      def subject_CLI
        Home_::CLI
      end
    end

    # ==

    HelpScreenCommonFourSections___ =
      ::Struct.new :usage, :description, :main_items, :secondary_items

    # ==

    class CommonMachine___

      # this is a would-be state machine (but actually it isn't) that
      # semi-parses lines of output following a common pattern into
      # a common structure. the pattern is this:
      #
      #     [ reason line ]
      #     splay line
      #     invite line
      #
      # the goal is that we are not *too* stringent with the parsing
      # here; that focused tests can effect more detailed assertion
      # using the structure we produce.

      def initialize
        @_lines = []
      end

      def receive_line line
        @_lines.push line
        NIL  # keep parsing
      end

      def finish
        stack = remove_instance_variable :@_lines
        @invite_line = stack.pop
        @invite_line || fail
        @_splay_line = stack.pop
        @_splay_line || fail
        @reason_line = stack.pop  # nil OK
        __init_index_of_splay_via_splay_line
        freeze
      end

      def __init_index_of_splay_via_splay_line
        _line = remove_instance_variable :@_splay_line
        _Index_of_etc = Zerk_lib_[].test_support::CLI::IndexOfSplay_via_Line
        @index_of_splay = _Index_of_etc.new( _line ).execute
        NIL
      end

      attr_reader(
        :index_of_splay,
        :invite_line,
        :reason_line,
      )
    end
    # ==
    # ==
  end
end
