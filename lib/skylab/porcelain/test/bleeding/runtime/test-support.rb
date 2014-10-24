require_relative '../test-support'

module Skylab::Porcelain::TestSupport::Bleeding::Runtime
  ::Skylab::Porcelain::TestSupport::Bleeding[ Runtime_TestSupport = self ]

  include Constants # so we can say `Bleeding` (the right one) in specs!

  Bleeding = self::Bleeding # #annoy -- *necessary* for the six-month @_todo's
  TestLib_ = TestLib_

  class Frame < ::Struct.new :klass, :argv, :debug
    include Constants
    TestLib_::Let[ self ]

    let :client do
      o = klass.new
      o.parent = parent_client
      o
    end

    let :parent_client do
      Callback_.test_support.call_digraph_listeners_spy.new(
        :do_debug_proc, -> { debug } )
    end

    let :result do
      parent_client.debug! if debug
      client.invoke argv
    end
  end

  module Runtime_InstanceMethods
    include Constants

    def initialize rt=nil
      self.parent = rt
      @program_name = 'DORP'
    end
  end

  module Constants
    Frame = Frame
    Runtime_InstanceMethods = Runtime_InstanceMethods
  end

  module ModuleMethods

    def argv *a
      let( :argv ) { a }
    end

    def frame description, *tags, &body_p
      context(description, *tags) do
        f = -> { r = _build_frame ; f = -> { r } ; r }
        let( :frame ) { instance_exec(& f ) }
        module_eval(& body_p)
      end
    end

    # --*-- DSL-y function ish --*--
    -> do
      usage_rx =  /usage.+DORP <action> \[opts\] \[args\]/i
      invite_rx =  /try DORP \[<action>\] -h for help/i
      define_method :specify_should_usage_invite do
        specify { should be_event(1, :help, usage_rx) }
        specify { should be_event(2, :help, invite_rx) }
      end
    end.call
    # --* end --*--
  end

  module InstanceMethods
    include Constants

    TestLib_::Let[ self ]

    def _build_frame
      Frame.new klass, argv, debug
    end

    let :subject do
      # frame itself is memoized with the closure hack
      frame.result # trigger it, possibly re-accessing a self-memoized value
      frame.parent_client.emission_a # from the Call_Digraph_Listeners_Spy__
    end
  end
end
