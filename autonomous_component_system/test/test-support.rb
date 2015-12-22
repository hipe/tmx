require 'skylab/autonomous_component_system'
require 'skylab/test_support'

module Skylab::Autonomous_Component_System::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  class << self

    def [] tcc
      tcc.extend Module_Methods___
      tcc.include Instance_Methods___
    end
  end  # >>

  define_singleton_method :lib, -> do

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

  module Module_Methods___

    def use sym
      TS_.lib( sym )[ self ]
    end

    def call_by_ & p

      dangerous_memoize :state_ do
        instance_exec( & p )
        _a = remove_instance_variable( :@event_log ).flush_to_array
        _root = remove_instance_variable :@__root
        State___.new(
          remove_instance_variable( :@__result ),
          _a,
          _root,
        )
      end
      NIL_
    end
  end

  State___ = ::Struct.new :result, :emission_array, :root

  module Instance_Methods___

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    # --

    def call_ * x_a

      if block_given?
        self._WRITE_ME
      end

      root = my_model_.new

      oes_p = event_log.handle_event_selectively

      _oes_p_p = -> _ do
        oes_p
      end

      @__result = Home_.edit x_a, root, & _oes_p_p
      @__root = root

      NIL_
    end

    def result_
      state_.result
    end

    def be_result_for_failure_
      eql false
    end
  end

  No_events_ = -> * i_a, & ev_p do
    fail "unexpected: #{ i_a.inspect }"
  end

  module TestLib_

    Expect_event = -> tcc do
      Callback_.test_support::Expect_Event[ tcc ]
    end

    Future_expect = -> tcc do
      Callback_.test_support::Future_Expect[ tcc ]
    end

    Memoizer_methods = -> tcc do
      TestSupport_::Memoization_and_subject_sharing[ tcc ]
    end
  end

  Callback_ = ::Skylab::Callback
  Callback_::Autoloader[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_ = true
  Home_ = ::Skylab::Autonomous_Component_System
  EMPTY_S_ = ''
  NIL_ = nil
  TS_ = self
  UNABLE_ = false
end
