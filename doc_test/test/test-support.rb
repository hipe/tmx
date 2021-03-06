require 'skylab/doc_test'
require 'skylab/test_support'

module Skylab::DocTest::TestSupport

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

    def testlib_
      @___TL ||= Common_.produce_library_shell_via_library_and_app_modules(
        TestLib___, self )
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport
  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  # -
    Use_method___ = -> sym do
      TS_.lib_( sym )[ self ]
    end
  # -

  # -

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    # -- support for making assertions

    def execute_unit_of_work_ uow  # explained in [#029.E]
      _hi = uow.express_into_under :___yielder_not_used, :____expag_not_used
      _hi == :___yielder_not_used || fail
      NIL
    end

    def want_actual_big_string_has_same_content_as_expected_ a_s, e_s
      want_actual_line_stream_has_same_content_as_expected_(
        line_stream_via_string_( a_s ),
        line_stream_via_string_( e_s ),
      )
    end

    def want_actual_line_stream_has_same_content_as_expected_ a_st, e_st
      TestSupport_::Want_Line::Streams_have_same_content[ a_st, e_st, self ]
    end

    def begin_expect_line_scanner_for_line_stream_ st
      TestSupport_::Want_Line::Scanner.via_stream st
    end

    def line_stream_via_string_ whole_string
      Line_stream_via_string_[ whole_string ]
    end

    # -- support for setting up

    -> do
      yes = true ; x = nil
      define_method :real_default_choices_ do
        if yes
          yes = false
          x = Home_::OutputAdapters_::Quickie.begin_choices
          x.init_default_choices
        end
        x
      end
    end.call

    def output_adapters_module_
      Home_::OutputAdapters_
    end

    def models_module_
      Home_::Models_
    end

    -> do
      cache = {}
      define_method :full_path_ do |tail_path|
        cache.fetch tail_path do
          x = ::File.join sidesystem_path_, tail_path
          cache[ tail_path ] = x
          x
        end
      end
    end.call

    hafp = nil
    define_method :home_asset_file_path_ do
      hafp ||= "#{ home_dir_path_ }#{ Autoloader_::EXTNAME }"
    end

    ssdp = nil
    define_method :sidesystem_path_ do
      ssdp ||= ::File.expand_path( '../../..', home_dir_path_ )
    end

    hdp = nil
    define_method :home_dir_path_ do
      hdp ||= Home_.dir_path
    end

    ted = nil
    define_method :the_empty_directory_ do
      ted ||= TestSupport_::Fixtures.directory :empty_esque_directory
    end

    tnd = nil
    define_method :the_noent_directory_ do
      tnd ||= TestSupport_::Fixtures.directory :not_here
    end

    def the_real_filesystem_
      The_real_filesystem_[]
    end

    def the_real_system_
      The_real_system__[]
    end
  # -

  module My_Non_Interactive_CLI

    def self.[] tcc
      Home_.lib_.zerk.test_support::Non_Interactive_CLI[ tcc ]
      tcc.include self
    end
    # -

      def build_invocation_for_want_stdout_stderr argv, sin, sout, serr, pn_s_a, * xtra

        Home_::CLI.new argv, sin, sout, serr, pn_s_a do |cli|

          cli.filesystem_by do
            this_filesystem_
          end

          cli.system_conduit_by do
            this_system_conduit_
          end
        end
      end
    # -
  end

  # --

  Common_ = ::Skylab::Common
  Lazy_ = Common_::Lazy

  # --

  Line_stream_via_string_ = -> do
    p = -> s do
      p = Home_.lib_.basic::String::LineStream_via_String
      p[ s ]
    end
    -> s do
      p[ s ]
    end
  end.call

  Want_no_emission_ = -> * a do
    fail "no: #{ a.inspect }"
  end

  Safe_localize_ = -> longer, shorter do
    Home_.lib_.basic::Pathname::Localizer[ shorter ][ longer ]
  end

  The_real_filesystem_ = Lazy_.call do
    Home_.lib_.system.filesystem
  end

  The_real_system__ = Lazy_.call do
    Home_.lib_.system_lib.lib_.open3  # #violation
  end

  # --

  Want_Event = -> tcc do
    Common_.test_support::Want_Emission[ tcc ]
  end

  Want_Line = -> tcc do
    TestSupport_::Want_line[ tcc ]
  end

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  # --

  Autoloader_ = Common_::Autoloader

  # --

  module TestLib___

    sidesys = Autoloader_.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]
  end

  # --

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Home_ = ::Skylab::DocTest

  EMPTY_A_ = Home_::EMPTY_A_
  DocTest = Home_  # only for generated tests, find it via (?!<::)DocTest\b
  EMPTY_S_ = Home_::EMPTY_S_
  NEWLINE_ = Home_::NEWLINE_
  NIL_ = nil
  NIL = nil  # #open [#sli-116.C]
  Stream_ = Home_::Stream_
  TS_ = self
end
# #tombstone: "case" testing DSL
# #tombstone: pre-zerk CLI support lib
