require 'skylab/code_metrics'
require 'skylab/test_support'

module Skylab::CodeMetrics::TestSupport

  def self.[] tcc
    tcc.extend Module_Methods___
    tcc.include Instance_Methods___
  end

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  Home_ = ::Skylab::CodeMetrics
  Common_ = Home_::Common_
  Autoloader_ = Common_::Autoloader
  Lazy_ = Common_::Lazy_

  module Module_Methods___

    cache = {}
    define_method :use do | sym |
      _ = cache.fetch sym do
        x = TestSupport_.fancy_lookup sym, TS_
        cache[ sym ] = x
        x
      end
      _[ self ]
    end
  end

  module Instance_Methods___

    define_singleton_method :_dangerous_memoize, TestSupport_::DANGEROUS_MEMOIZE

    _dangerous_memoize :toplevel_helpscreen_actions_ do

      _x = toplevel_help_screen_.lookup 'actions'
      bx = Common_::Box.new
      _x.children.each do | cx |

        # #gotacha :[#012]: this is nasty: what the treeifier does with blank
        # lines is context-dependant for now (#watching [#ze-054.1-1].) now
        # consider the following three (at present) facts put together:
        #
        #   • "ping" has no desc lines.
        #
        #   • the "actions" section ends with a blank line.
        #
        #   • the order that the action items comes out on help screens
        #     is volatile: it depends on on whether we have run our "model-"
        #     level tests or not.
        #
        # given the above, whether or not that final blank line will be
        # counted as part of an action's descrption depends on whether
        # "ping" occcurs as the last item. hence this is flickering unless
        # we do the below.
        #
        # probably the right fix for this is to make the order of actions
        # rigid but incurs its own kind of costs..

        if NEWLINE_ == cx.x.string
          # you may only hit this line when running multiple tests (-order)
          next
        end

        bx.add cx.x.get_column_A_content, cx
      end
      bx
    end

    _dangerous_memoize :toplevel_help_screen_ do

      invoke '-h'
      flush_invocation_to_help_screen_oriented_state
    end

    def subject_CLI
      Home_::CLI
    end

    _dangerous_memoize :memoized_invocation_strings_for_expect_stdout_stderr_ do
      get_invocation_strings_for_expect_stdout_stderr
    end

    s = '[CoMe]'
    define_method :get_invocation_strings_for_expect_stdout_stderr_ do
      [ s ]  # some places need this as mutable (to build sub-program name)
    end

    def ignore_emissions_whose_terminal_channel_is_in_this_hash
      NOTHING_
    end

    def subject_API
      Home_.application_kernel_
    end

    def handle_event_selectively_
      event_log.handle_event_selectively
    end

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  # --

  Build_real_system_services_ = -> o do
    Home_::Mondrian_[]::SystemServices___.new o.be_verbose, o.debug_IO
  end

  Stream_ = Home_::Stream_

  # -- for `use`

  CLI_Expectations = -> tcc do
    Home_.lib_.brazen.test_support.lib( :CLI_support_expectations )[ tcc ]
  end

  Expect_Event = -> tcc do
    Common_.test_support::Expect_Emission[ tcc ]
  end

  Expect_Emission_Fail_Early = -> tcc do
    Common_.test_support::Expect_Emission_Fail_Early[ tcc ]
  end

  Expect_Stdout_Stderr = -> tcc do
    tcc.include TestSupport_::Expect_Stdout_Stderr::Test_Context_Instance_Methods
  end

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  # --

  Fixture_file_ = -> s do
    ::File.join Fixture_file_directory_[], s
  end

  Fixture_file_directory_ = Common_.memoize do
    ::File.join Fixture_tree_directory_[], 'fixture-files-one'
  end

  Fixture_tree_directory_ = Common_.memoize do
    ::File.join TS_.dir_path, 'fixture-trees', 'fixture-tree-one'
  end

  Fixture_tree_two_ = Lazy_.call do
    ::File.join TS_.dir_path, 'fixture-trees/fixture-tree-two'
  end

  # --

  module FixtureAssetNodesToLoadOnce
    Autoloader_[ self ]
  end

  # --

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  CONST_SEP_ = Home_::CONST_SEP_
  EMPTY_S_ = Home_::EMPTY_S_
  NEWLINE_ = Home_::NEWLINE_
  NIL_ = nil
  NIL = nil  # open [#sli-016.C]
  NOTHING_ = nil
  SPACE_ = Home_::SPACE_
  TS_ = self
end
