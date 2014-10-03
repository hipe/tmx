require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Brazen::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self ]

  Brazen_ = ::Skylab::Brazen

  TestLib_ = ::Module.new

  module CONSTANTS
    Brazen_ = Brazen_
    EMPTY_S_ = ''.freeze
    Entity_ = Brazen_::Entity_
    SPACE_ = ' '.freeze
    TestLib_ = TestLib_
    TestSupport_ = TestSupport_
  end

  module InstanceMethods

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    def event_expression_agent
      @eea ||= begin
        $stderr.puts "OHAI"
        Brazen_::API.expression_agent_class.new Brazen_::API.application_kernel
      end
    end
  end

  module TestLib_

    memoize = Brazen_::Callback_.memoize

    Expect_Event = -> test_context_cls do
      TS_::Expect_Event[ test_context_cls ]
    end

    Tmpdir = memoize[ -> do
      o = Brazen_::Lib_::HL__[]
      o::IO::Filesystem::Tmpdir.new(
        o::System.defaults.dev_tmpdir_pathname.join( 'brzn' ).to_path )
    end ]

  end
end
