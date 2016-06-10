require 'skylab/test_support'

module Skylab::TestSupport::TestSupport

  class << self

    def transitional_ tcc
      tcc.include InstanceMethods
    end
  end  # >>

  Home_ = ::Skylab::TestSupport

  Home_::Regret[ Top_TS_ = self, ::File.dirname( __FILE__ ) ]

  extend Home_::Quickie

  module InstanceMethods

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      @debug_IO ||= Home_.lib_.stderr
    end
  end

  class << self

    def doc_path_ s
      @___doc_path ||= ::File.join( _sidesys_path, 'doc' )
      ::File.join @___doc_path, s
    end

    def noent_path_
      @___noent_path ||= ::File.join( Home_.dir_pathname.to_path, 'noent.file' )
    end

    def test_path_ s
      @___test_path ||= ::File.join( _sidesys_path, 'test' )
      ::File.join @___test_path, s
    end

    def _sidesys_path
      @___sidesys_path ||= ::File.expand_path(
        '../../..', Home_.dir_pathname.to_path )
    end
  end  # >>

  module Constants
    EMPTY_A_ = Home_::EMPTY_A_
    EMPTY_S_ = Home_::EMPTY_S_
    LIB_  = Home_.lib_
    Home_ = Home_
    Top_TS_ = Top_TS_
  end

  TS_ = self
end

# :+tombstone: 'mock_FS' as bundle
