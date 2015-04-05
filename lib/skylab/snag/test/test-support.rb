require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Snag::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self ]

  extend TestSupport_::Quickie

  module ModuleMethods

    def use sym

      TS_.const_get(
        Callback_::Name.via_variegated_symbol( sym ).as_const, false
      )[ self ]

      NIL_
    end

    def with_invocation * i_a
    end

    def with_manifest s
    end

    def with_tmpdir_patch
    end

    def with_tmpdir
    end
  end

  module InstanceMethods

    def tmpdir
      @tmpdir ||= Memoize_.call :tmpdir do
        __build_tmpdir
      end
    end

    def __build_tmpdir

      TestSupport_.tmpdir.new(
        :path, Snag_.lib_.system.filesystem.tmpdir_pathname.
          join( 'snaggle' ).to_path,
        :be_verbose, do_debug,
        :debug_IO, debug_IO )
    end

    # ~ support & officious

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  Expect_Event = -> tcm do
    Callback_.test_support::Expect_Event[ tcm ]
  end

  Snag_ = ::Skylab::Snag

  Callback_ = Snag_::Callback_

  NIL_ = nil

end
