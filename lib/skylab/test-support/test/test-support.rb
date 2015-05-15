require_relative '../core'

module Skylab::TestSupport::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ Top_TS_ = self ]

  extend TestSupport_::Quickie

  module InstanceMethods

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      @debug_IO ||= TestSupport_.lib_.stderr
    end
  end

  class << self

    def skylab_dir_path
      @___sdp ||= ::File.dirname TestSupport_.dir_pathname.to_path
    end

    def universal_skylab_bin_path
      TestSupport_.lib_.system_lib.services.defaults.bin_path
    end
  end  # >>

  module Constants
    EMPTY_A_ = TestSupport_::EMPTY_A_
    EMPTY_S_ = TestSupport_::EMPTY_S_
    LIB_  = TestSupport_.lib_
    TestSupport_ = TestSupport_
    Top_TS_ = Top_TS_
  end
end

# :+tombstone: 'mock_FS' as bundle
