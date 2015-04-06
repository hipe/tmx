require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Snag::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self ]

  extend TestSupport_::Quickie

  module ModuleMethods

    def use sym, * x_a

      if x_a.length.nonzero?
        rest = [ x_a ]
      end

      TS_.const_get(
        Callback_::Name.via_variegated_symbol( sym ).as_const, false
      )[ self, * rest ]

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

    def subject_API  # #hook-out for expect event
      Snag_::API
    end

    def black_and_white_expression_agent_for_expect_event  # ditto
      Snag_.lib_.brazen::API.expression_agent_instance
    end
  end

  module Expect_CLI

    class << self
      def [] tcm, x_a

        require TS_.dir_pathname.join( 'modality-integrations/expect-cli' ).to_path
        self[ tcm, x_a ]
      end
    end  # >>
  end

  Expect_Event = -> tcm do
    Callback_.test_support::Expect_Event[ tcm ]
  end

  Expect_Stdout_Stderr = -> tcm do

    tcm.include TestSupport_::Expect_Stdout_Stderr::Test_Context_Instance_Methods
    tcm.send :define_method, :expect, tcm.instance_method( :expect )  # :+#this-rspec-annoyance
    NIL_
  end

  Snag_ = ::Skylab::Snag

  Callback_ = Snag_::Callback_

  NIL_ = nil

end
