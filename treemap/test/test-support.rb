require 'skylab/treemap'
require 'skylab/test_support'

module Skylab::Treemap::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self, ::File.dirname( __FILE__ ) ]

  extend TestSupport_::Quickie

  module ModuleMethods

    def use sym
      :expect_event == sym or fail
      Home_::Callback_.test_support::Expect_Event[ self ]
    end
  end

  module InstanceMethods

    def debug!
      @do_debug = true
    end
    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    def subject_API
      Home_.application_kernel_
    end

    def black_and_white_expression_agent_for_expect_event
      Home_.lib_.brazen::API.expression_agent_instance
    end
  end

  Fixture_file_ = -> do

    p = -> path do
      dirname = TS_.dir_pathname.join( 'fixture-files' ).to_path
      p = -> path_ do
        ::File.join dirname, path_
      end
      p[ path ]
    end

    -> path do
      p[ path ]
    end
  end.call

  class << self
    def string_IO
      require 'stringio'
      ::StringIO
    end
  end  # >>

  Home_ = ::Skylab::Treemap
end
