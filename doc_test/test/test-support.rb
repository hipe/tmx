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
  extend TestSupport_::Quickie

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

    def expect_actual_big_string_has_same_content_as_expected_ a_s, e_s
      expect_actual_line_stream_has_same_content_as_expected_(
        line_stream_via_string_( a_s ),
        line_stream_via_string_( e_s ),
      )
    end

    def expect_actual_line_stream_has_same_content_as_expected_ a_st, e_st
      TestSupport_::Expect_Line::Streams_have_same_content[ a_st, e_st, self ]
    end

    def begin_expect_line_scanner_for_line_stream_ st
      TestSupport_::Expect_Line::Scanner.via_stream st
    end

    def line_stream_via_string_ whole_string
      Home_.lib_.basic::String.line_stream whole_string
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

    def magnetics_module_
      Home_::Magnetics_
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
      hafp ||= "#{ home_dir_path_ }#{ Autoloader_::EXTNAME_ }"
    end

    ssdp = nil
    define_method :sidesystem_path_ do
      ssdp ||= ::File.expand_path( '../../..', home_dir_path_ )
    end

    hdp = nil
    define_method :home_dir_path_ do
      hdp ||= Home_.dir_pathname.to_path
    end

    ted = nil
    define_method :the_empty_directory_ do
      ted ||= TestSupport_::Fixtures.directory :empty_esque_directory
    end

    tnd = nil
    define_method :the_noent_directory_ do
      tnd ||= TestSupport_::Fixtures.directory :not_here
    end
  # -

  module My_Non_Interactive_CLI

    def self.[] tcc
      Home_.lib_.zerk.test_support::Non_Interactive_CLI[ tcc ]
      tcc.include self
    end
    # -
      def subject_CLI
        Home_::CLI
      end
    # -
  end

  # --

  Common_ = ::Skylab::Common
  Lazy_ = Common_::Lazy

  # --

  Safe_localize_ = -> longer, shorter do
    Home_.lib_.basic::Pathname::Localizer[ shorter ][ longer ]
  end

  # --

  Expect_Event = -> tcc do
    Common_.test_support::Expect_Event[ tcc ]
  end

  Expect_Line = -> tcc do
    TestSupport_::Expect_line[ tcc ]
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

  DASH_ = '-'
  DocTest = Home_  # only for generated tests, find it via (?!<::)DocTest\b
  EMPTY_S_ = Home_::EMPTY_S_
  NEWLINE_ = Home_::NEWLINE_
  NIL_ = nil
  TS_ = self
  UNDERSCORE_ = '_'
end
# #tombstone: pre-zerk CLI support lib
