require_relative '../test-support'

module ::Skylab::Porcelain::TestSupport::Bleeding::Runtime
  ::Skylab::Porcelain::TestSupport::Bleeding[ Runtime_TestSupport = self ]

  include CONSTANTS # so we can say `Bleeding` (the right one) in specs!

  Bleeding = self::Bleeding # #annoy -- *necessary* for the six-month @_todo's

  class Frame < ::Struct.new :klass, :argv, :debug
    include CONSTANTS
    extend MetaHell::Let

    let :client do
      o = klass.new
      o.parent = parent_client
      o
    end

    let :parent_client do
      o = TestSupport::EmitSpy.new
      o.format = -> e { "#{e.type.inspect}<-->#{e.message.inspect}" }
      o
    end

    let :result do
      parent_client.debug! if debug
      client.invoke argv
    end
  end


  module Runtime_InstanceMethods
    include CONSTANTS

    def emit k, v
      parent.emit Event_Simplified.new(k, unstylize(v))
    end

    def initialize rt=nil
      self.parent = rt
      @program_name = 'DORP'
    end
  end


  module CONSTANTS
    Frame = Frame
    Runtime_InstanceMethods = Runtime_InstanceMethods
  end


  module ModuleMethods

    def argv *a
      let( :argv ) { a }
    end

    def frame description, *tags, &body_f
      context(description, *tags) do
        f = -> { r = _build_frame ; f = -> { r } ; r }
        let( :frame ) { instance_exec(& f ) }
        module_eval(& body_f)
      end
    end

    # --*-- DSL-y function ish --*--
    -> do
      usage_re =  /usage.+DORP <action> \[opts\] \[args\]/i
      invite_re =  /try DORP \[<action>\] -h for help/i
      define_method :specify_should_usage_invite do
        specify { should be_event(1, :help, usage_re) }
        specify { should be_event(2, :help, invite_re) }
      end
    end.call
    # --* end --*--
  end


  module InstanceMethods
    include CONSTANTS
    extend MetaHell::Let

    def _build_frame
      Frame.new klass, argv, debug
    end

    let :subject do
      # frame itself is memoized with the closure hack
      frame.result # trigger it, possibly re-accessing a self-memoized value
      frame.parent_client.emitted # expecting an array from an emit spy
    end
  end
end
