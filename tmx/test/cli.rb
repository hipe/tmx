module Skylab::TMX::TestSupport

  module CLI

    def self.[] tcc

      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___
    end

    module ModuleMethods___

      def given_test_directories s_a
        define_method :prepare_subject_CLI_invocation do |cli|
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
        want_each_on_stderr_by( & mach.method( :receive_line ) )
        want_fail
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

      def define_mock_installation_ & p
        # a convenience exposure of this lower-level thing
        TS_::Installation::StubInstallation.define( & p )
      end

      # -- setup structures for assertion

      def want_common_help_screen_sections_by_

        sct = HelpScreenCommonFourSections___.new

        o = Zerk_test_support_[]::CLI::Want_Section_Fail_Early.define

        yield sct, o

        spy = o.finish.to_spy_under self
        io = spy.spying_IO
        want_each_on_stderr_by do |line|
          io.puts line
          NIL  # keep parsing
        end
        want_succeed  # big money

        spy.finish

        sct
      end

      # -- assert

      def want_failed_normally_
        want "try 'tmz -h'"
        want_fail
      end

      # --

      def prepare_subject_CLI_invocation cli
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

    HelpScreenCommonFourSections___ = ::Struct.new(
      :usage,
      :description,
      :main_items,
      :secondary_items,
    ) do
      def diff_against other
        Zerk_test_support_[]::CLI::WantSectionDiff_via_TwoScreens[ self, other ]
      end
    end

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
        @index_of_splay = _Index_of_etc[ _line ]
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
