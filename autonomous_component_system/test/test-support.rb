require 'skylab/autonomous_component_system'
require 'skylab/test_support'

module Skylab::Autonomous_Component_System::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  TestSupport_::Regret[ TS_ = self, ::File.dirname( __FILE__ ) ]

  module ModuleMethods

    def use sym
      TS_.lib( sym )[ self ]
    end
  end

  TS_.send :define_singleton_method, :lib, -> do

    cache_h = {}

    -> sym do
      cache_h.fetch sym do

        s = sym.id2name
        const = :"#{ s[ 0 ].upcase }#{ s[ 1 .. -1 ] }"
        x = if TestLib_.const_defined? const, false
          TestLib_.const_get const
        else
          TestSupport_.fancy_lookup sym, TS_
        end
        cache_h[ sym ] = x
        x
      end
    end
  end.call

  module InstanceMethods

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  No_events_ = -> * i_a, & ev_p do
    fail "unexpected: #{ i_a.inspect }"
  end

  module TestLib_

    Future_expect = -> tcc do
      Callback_.test_support::Future_Expect[ tcc ]
    end

    Memoizer_methods = -> tcc do
      TestSupport_::Memoization_and_subject_sharing[ tcc ]
    end
  end

  Callback_ = ::Skylab::Callback
  Home_ = ::Skylab::Autonomous_Component_System
  NIL_ = nil
end
