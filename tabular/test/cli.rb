module Skylab::Tabular::TestSupport

  module CLI

    def self.[] tcc

      tcc.send :define_singleton_method, :given, TheMethodCalledGiven___
      tcc.include InstanceMethods___
    end

    # ==
    # -

      TheMethodCalledGiven___ = -> & p do
        define_method :the_definition_for_tab do
          p
        end
      end

    # -
    # ==

    module InstanceMethods___

      # -- these basics (aren't above at writing)

      def debug!
        @do_debug = true
      end

      attr_reader :do_debug

      def debug_IO
        TestSupport_.debug_IO
      end

      # -- setup

      def non_interactive & p

        _mock_stdin = if block_given?
          MockSTDIN___.new p
        else
          NON_INTERACTIVE_STDIN___
        end

        @tab_givens.mock_stdin = _mock_stdin
      end

      def yes_interactive

        @tab_givens.mock_stdin = INTERACTIVE_STDIN___
      end

      def argv * argv
        @tab_givens.ARGV = argv
      end

      # -- assert

      # ~ (sadly..)

      def expect_on_stderr s
        tab_did || tab_init
        super s
      end

      def expect_on_stdout s
        tab_did || tab_init
        super s
      end

      def tab_init
        @tab_givens = Givens___.new
        _p = the_definition_for_tab
        instance_exec( & _p )
        givens = remove_instance_variable :@tab_givens
        @tab_did = true

        @tab_stdin = givens.mock_stdin

        invoke_via_argv givens.ARGV
      end

      attr_reader :tab_did

      def expect_invite_etc_
        expect_usage_line_
        expect "use 'tab -h' for help"
        expect_failed
      end

      def expect_usage_line_
        expect_on_stderr "usage: '(e.g) cat some-file | tab [options]'"
      end

      # --

      def prepare_CLI cli
        NOTHING_
      end

      define_method :program_name_string_array, ( Lazy_.call do
        %w( tab )
      end )

      def zerk_niCLI_fail_early_stdin
        remove_instance_variable :@tab_stdin
      end

      def subject_CLI
        Home_::Operations_::InferTable::CLI
      end
    end

    # =

    Givens___ = ::Struct.new :ARGV, :mock_stdin

    # (the below are #[#sy-024])

    class MockSTDIN___

      def initialize p
        lines = []
        _y = ::Enumerator::Yielder.new { |line| lines.push line }
        p[ _y ]
        @__line_stream = Stream_[ lines ]
      end

      def gets
        @__line_stream.gets
      end

      def tty?
        false
      end
    end

    module NON_INTERACTIVE_STDIN___ ; class << self

      def gets
        NOTHING_
      end

      def tty?
        false
      end
    end ; end

    module INTERACTIVE_STDIN___ ; class << self

      def tty?
        true
      end
    end ; end

    # ==

    Non_Interactive_CLI_Fail_Early = -> tcc do
      Zerk_lib_[].test_support::Non_Interactive_CLI::Fail_Early[ tcc ]
    end

    # ==

    Zerk_lib_ = Lazy_.call do
      Home_.lib_.zerk
    end

    # ==
  end
end
# #tombstone: full reconception from ancient [as]
