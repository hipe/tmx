require_relative '../lib/skylab/doc_test'  # #while-open [#016]
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

    # --

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
          x = ::File.join sidesystem_dir_path_, tail_path
          cache[ tail_path ] = x
          x
        end
      end
    end.call

    ssdp = nil
    define_method :sidesystem_dir_path_ do
      ssdp ||= ::File.expand_path( '../../..', Home_.dir_pathname.to_path )
    end

  # -

  # --

  module API
    def self.[] tcc
    end
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

  Common_ = ::Skylab::Common
  Autoloader__ = Common_::Autoloader

  # --

  module TestLib___

    sidesys = Autoloader__.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]
  end

  # --

  Autoloader__[ self, ::File.dirname( __FILE__ ) ]

  Home_ = ::Skylab::DocTest

  EMPTY_S_ = Home_::EMPTY_S_
  NEWLINE_ = Home_::NEWLINE_
  NIL_ = nil
  TS_ = self
end
