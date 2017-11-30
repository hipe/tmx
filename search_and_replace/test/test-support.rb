require 'skylab/search_and_replace'
require 'skylab/test_support'

module Skylab::SearchAndReplace::TestSupport

  class << self

    def [] tcc
      tcc.send :define_singleton_method, :use, Use_method___
      tcc.include self
    end

    cache = {}
    define_method :lib_ do |sym|
      cache.fetch sym do
        x = TestSupport_.fancy_lookup sym, TS_
        cache[ sym ] = x
        x
      end
    end
  end  # >>

  Common_ = ::Skylab::Common
  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  TestSupport_::Memoization_and_subject_sharing[ self ]

  # -

    Use_method___ = -> sym do
      TS_.lib_( sym )[ self ]
    end

  # -

    # -- expect

    def want_these_lines_in_array_ a, & p
      TestSupport_::Want_these_lines_in_array[ a, p, self ]
    end

    # -- setup

    # ~ FS

    def build_my_tmpdir_controller_  # NOT prepared (emptied)

      _path = ::File.join Home_.lib_.system.defaults.dev_tmpdir_path, '[sa]'

      Home_.lib_.system_lib::Filesystem::Tmpdir.with(
        :path, _path,
        :be_verbose, do_debug,
        :debug_IO, debug_IO,
        :max_mkdirs, 2,
      )
    end

    memoize :this_test_directory_ do

      dir = ::File.join TS_.dir_path, '6-interactive-CLI'
      ::File.directory? dir or fail
      dir
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

      Common_::Stream.via_item _path
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

    # ~

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

    def _Nth_match_controller d, es

      mc = es.first_match_controller

      d.times do
        _mc_ = mc.next_match_controller
        _mc_ or ::Kernel._SANITY  # #todo
        mc = _mc_
      end

      mc
    end

    def match_controller_array_for_ es
      match_controller_stream_for_( es ).to_a
    end

    def match_controller_stream_for_ es

      curr = es
      Common_.stream do
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

    # ~ [co] "want emission [fail early]"

    def ignore_emissions_whose_terminal_channel_is_in_this_hash
      NOTHING_
    end

    def subject_API
      Home_::API
    end

    # --

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  # -

  # -- modality test support lib nodes (short stowaways)

  module My_Interactive_CLI

    class << self

      def [] tcc
        TestSupport_::Memoization_and_subject_sharing[ tcc ]
        Require_zerk__[]
        Zerk_.test_support::Want_Screens[ tcc ]
        tcc.include self ; nil
      end
    end  # >>

    # ~ setup

    def subject_CLI
      Home_::CLI
    end

    def stdout_is_expected_to_be_written_to
      true
    end

    # ~ assertion

    def is_on_frame_number_with_buttons_ d
      expect( stack ).to be_at_frame_number d
      buttonesques
    end

    _RX = "/h.n#{}k.nl..p.r/i"
    define_method :hinkenloooper_regexp_string_ do
      _RX
    end
  end

  module My_API

    def self.[] tcc
      Require_zerk__[]
      Zerk_.test_support::API[ tcc ]
      tcc.include self
    end

    def build_root_ACS

      # _p = event_log.handle_event_selectively  # #cold-model

      root = Home_::Root_Autonomous_Component_System_.new
      root._init_with_defaults
      root
    end  # •cp1
  end

  # -- test support lib nodes (short)

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  Want_Event = -> tcc do
    Common_.test_support::Want_Emission[ tcc ]
  end

  Zerk_Help_Screens = -> tcc do
    Require_zerk__[]
    Zerk_.test_support::CLI::Want_Section_Coarse_Parse[ tcc ]
  end

  # --

  Require_zerk__ = Common_::Lazy.call do
    Zerk_ = Home_.lib_.zerk ; nil
  end

  Autoloader_ = Common_::Autoloader

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]
  Home_ = ::Skylab::SearchAndReplace

  Stream_ = -> a, & p { Common_::Stream.via_nonsparse_array a, & p }

  EMPTY_A_ = []  # Home_::EMPTY_A_
  EMPTY_S_ = Home_::EMPTY_S_
  NEWLINE_ = Home_::NEWLINE_
  NIL_ = nil
  NIL = nil  # #open [#sli-116.C]
  NOTHING_ = nil
  TS_ = self
end
