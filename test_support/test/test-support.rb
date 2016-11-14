require 'skylab/test_support'

module Skylab::TestSupport::TestSupport

  class << self

    def [] tcc

      tcc.send :define_singleton_method, :use, Use_method___
      tcc.include InstanceMethods
    end

    def doc_path_ s
      @___doc_path ||= ::File.join( _sidesystem_path, 'doc' )
      ::File.join @___doc_path, s
    end

    def noent_path_
      @___noent_path ||= ::File.join( Home_.dir_path, 'noent.file' )
    end

    def test_path_ s
      @___test_path ||= ::File.join( _sidesystem_path, 'test' )
      ::File.join @___test_path, s
    end

    def _sidesystem_path
      @___ssp ||= ::File.expand_path '../../..', Home_.dir_path
    end

    cache = {}
    define_method :lib_ do |sym|
      cache.fetch sym do
        x = Home_.fancy_lookup sym, TS_
        cache[ sym ] = x
        x
      end
    end
  end  # >>

  Home_ = ::Skylab::TestSupport
  extend Home_::Quickie

  # -
    Use_method___ = -> sym do
      TS_.lib_( sym )[ self ]
    end
  # -

  module InstanceMethods

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      @debug_IO ||= Home_.lib_.stderr
    end

    # --

    def fixture_file__ filename
      ::File.join Home_::Fixtures.files_path, filename
    end

    ftcache = {}
    define_method :fixture_tree do |sym, * s_a|
      path = ftcache.fetch sym do
        x = Home_::Fixtures.tree sym
        ftcache[ sym ] = x
        x
      end
      if s_a.length.zero?
        path
      else
        ::File.join path, * s_a
      end
    end
  end

  # --

  Expect_Emission_Fail_Early = -> tcc do
    Common_.test_support::Expect_Emission_Fail_Early[ tcc ]
  end

  Expect_Event = -> tcc do
    Common_.test_support::Expect_Emission[ tcc ]
  end

  Memoizer_Methods = -> tcc do
    Home_::Memoization_and_subject_sharing[ tcc ]
  end

  The_Method_Called_Let = -> tcc do
    Home_::Let[ tcc ]
  end

  # --

  Zerk_test_support_ = -> do
    Home_.lib_.zerk.test_support
  end

  # --

  Common_ = Home_::Common_
  Autoloader_ = Common_::Autoloader
  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Lazy_ = Common_::Lazy
  TS_ = self
  UNABLE_ = false
end
# :+tombstone: 'mock_FS' as bundle
