require 'skylab/myterm'
require 'skylab/test_support'

module Skylab::MyTerm::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self, ::File.dirname( __FILE__ ) ]

  extend TestSupport_::Quickie

  module ModuleMethods

    def use sym

      TS_.__lib( sym )[ self ]
    end
  end

  module InstanceMethods

    def debug!
      @do_debug = true
    end

    def debug_IO
      TestSupport_.debug_IO
    end

    def call_ * x_a  # assumes future_expect for now

      bc = Home_.application_kernel_.bound_call_via_mutable_iambic(
        x_a, & fut_p )

      @result = bc.receiver.send bc.method_name, * bc.args, & bc.block

      future_is_now  # assert no unexpected events

      NIL_
    end
  end

  class << self

    def __lib sym
      s = sym.id2name
      TestLib_.const_get "#{ s[ 0 ].upcase }#{ s[ 1..-1 ] }", false
    end
  end  # >>

  module TestLib_

    Danger_memo = -> tcc do

      tcc.send :define_singleton_method,
        :dangerous_memoize_,
        TestSupport_::DANGEROUS_MEMOIZE
    end

    Future_expect = -> tcc do  # test context class
      Callback_.test_support::Future_Expect[ tcc ]
    end
  end

  Callback_ = ::Skylab::Callback
  Home_ = ::Skylab::MyTerm
  NIL_ = nil
end
