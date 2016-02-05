require 'skylab/search_and_replace'
require 'skylab/test_support'

module Skylab::SearchAndReplace::TestSupport

  class << self

    def [] tcc
      tcc.send :define_singleton_method, :use, Use_method___
      tcc.include self
    end

    cache = {}
    define_method :lib_ do | sym |
      cache.fetch sym do
        x = TestSupport_.fancy_lookup sym, TS_
        cache[ sym ] = x
        x
      end
    end
  end  # >>

  Callback_ = ::Skylab::Callback
  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  TestSupport_::Memoization_and_subject_sharing[ self ]

  # -

    Use_method___ = -> sym do
      TS_.lib_( sym )[ self ]
    end

  # -

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    # -- setup

    memoize :this_directory_that_exists_ do

      _loc = caller_locations( 3 ).fetch 0
      _ = ::File.dirname _loc.path
      _ = ::File.expand_path _  # keep relative dirs out of tests
      '4-interactive-CLI-integration' == ::File.basename( _ ) or fail
      _
    end

    dangerous_memoize :the_wazizzle_worktree_ do

      my_fixture_tree_ '3-the-wazizzle-worktree'
    end

    memoize :_ONE_LINE_FILE do
      'one-line.txt'
    end

    memoize :_THREE_LINES_FILE do
      'three-lines.txt'
    end

    def build_stream_for_single_path_to_file_with_three_lines_

      _path = TestSupport_::Fixtures.file :three_lines

      Callback_::Stream.via_item _path
    end

    def common_haystack_directory_
      TestSupport_::Fixtures.files_path
    end

    dangerous_memoize :common_functions_dir_ do
      my_fixture_tree_ '2-my-functions'
    end

    def my_fixture_tree_ entry_s
      my_fixture_trees_[ entry_s ]
    end

    def my_fixture_trees_
      TS_::Fixture_Trees
    end

    def basename_ path
      ::File.basename path
    end

    def magnetics_
      Home_::Magnetics_
    end

    memoize :no_events_ do
      -> * i_a, & ev_p do
        ::Kernel.fail "no: #{ i_a.inspect }"
      end
    end

    # -- assertion (shared)

    def include_alternation_for_ s_a
      _ = s_a.map do |s|
        "'#{ s }'"
      end.join ' | '

      be_include _
    end

    def match_controller_array_for_ es
      match_controller_stream_for_( es ).to_a
    end

    def match_controller_stream_for_ es

      curr = es
      Callback_.stream do
        curr = curr.next_match_controller
        curr
      end
    end

    # ~ string-related assertion assistance

    def unindent_ s  # mutates original! and results in it!
      Home_.lib_.basic::String.mutate_by_unindenting s
      s
    end

    # -- hook-ins/outs

    # ~ [ca] "expect event"

    def subject_API
      Home_::API
    end

    # ~ [br] "expect interactive"

    memoize :interactive_bin_path do
      self._REDO
      ::File.join TS_._MY_BIN_PATH, 'tmx-beauty-salon search-and-r'
    end

  # -- test support lib nodes

  module Interactive_CLI

    def self.[] tcc ; tcc.include self end

    # ~ setup

    def subject_CLI
      Home_::CLI
    end

    def stdout_is_expected_to_be_written_to
      true
    end

    # ~ assertion

    def is_on_frame_number_with_buttons_ d
      stack.should be_at_frame_number d
      buttonesques
    end

    _RX = "/h.n#{}k.nl..p.r/i"
    define_method :hinkenloooper_regexp_string_ do
      _RX
    end
  end

  module My_API

    def self.[] tcc
      Require_Zerk_[]
      Zerk_.test_support::API[ tcc ]
      tcc.include self
    end

    def build_root_ACS

      _oes_p = event_log.handle_event_selectively

      root = Home_::Root_Autonomous_Component_System_.new( & _oes_p )
      root._init_with_defaults
      root
    end  # •cp1
  end

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  Expect_Event = -> tcc do
    Callback_.test_support::Expect_Event[ tcc ]
  end

  Expect_Screens = -> tcc do
    Require_Zerk_[]
    Zerk_.test_support.lib( :expect_screens )[ tcc ]
  end

  # --

  Require_Zerk_ = Callback_::Lazy.call do
    Zerk_ = Home_.lib_.zerk ; nil
  end

  Callback_::Autoloader[ self, ::File.dirname( __FILE__ ) ]
  Home_ = ::Skylab::SearchAndReplace

  EMPTY_A_ = []  # Home_::EMPTY_A_
  EMPTY_S_ = Home_::EMPTY_S_
  NEWLINE_ = Home_::NEWLINE_
  NIL_ = nil
  TS_ = self
end
