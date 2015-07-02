require_relative '../core'

module Skylab::TestSupport::TestSupport

  Home_ = ::Skylab::TestSupport

  Home_::Regret[ Top_TS_ = self ]

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

    def skylab_dir_path
      @___sdp ||= ::File.dirname Home_.dir_pathname.to_path
    end

    def universal_skylab_bin_path
      Home_.lib_.system_lib.services.defaults.bin_path
    end
  end  # >>

  module Constants
    EMPTY_A_ = Home_::EMPTY_A_
    EMPTY_S_ = Home_::EMPTY_S_
    LIB_  = Home_.lib_
    Home_ = Home_
    Top_TS_ = Top_TS_
  end
end

# :+tombstone: 'mock_FS' as bundle
