require_relative '../core'
require 'skylab/test-support/core'

module Skylab::MetaHell::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ self ]
  TestSupport_::Quickie.enable_kernel_describe

  module ModuleMethods

    def use sym

      _const = Callback_::Name.via_variegated_symbol( sym ).as_const
      MetaHell_::TestSupport.const_get( _const, false )[ self ]
    end

    def memoize_ sym, & p
      define_method sym, Callback_.memoize( & p )
    end
  end

  Callback_ = ::Skylab::Callback
  MetaHell_ = ::Skylab::MetaHell

  module InstanceMethods


    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    let :o do
      klass.new
    end
  end

  Expect_Event = -> tcm do

    Callback_.test_support::Expect_Event[ tcm ]

    tcm.send :define_method, :black_and_white_expression_agent_for_expect_event do
      MetaHell_.lib_.brazen::API.expression_agent_instance
    end

    NIL_
  end

  NIL_ = nil

  module Constants

    Callback_ = Callback_
    MetaHell_ = MetaHell_
    TestSupport_ = TestSupport_
  end
end
