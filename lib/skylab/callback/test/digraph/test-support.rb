require_relative '../test-support'

module Skylab::Callback::TestSupport::Digraph

  ::Skylab::Callback::TestSupport[ Digraph_TestSupport = self ] # #regret

  include Constants

  Callback_ = Callback_

  Callback_::Lib_::Quickie[ self ]

  module ModuleMethods
    include Constants
    include Callback_::Lib_::Class[]::Creator::ModuleMethods

    def inside &b                 # define the dsl-ish klass body to be somthing
      b or fail 'give a block'    # other than nothing (below)
      define_method :inside do b end
    end

    def memoize name, func
      define_method name, & Callback_::Lib_::Memoize[ func ]
      nil
    end
  end

  B_D_E___ = -> * a, i, esg do
    if a.length.zero?
      Mock_Old_Event__.new nil, i  # covered
    else
      Mock_Old_Event__.new a, i
    end
  end

  class Mock_Old_Event__

    def initialize x_a, i
      @event_id = Event_ID___[]
      @is_touched = false
      @payload_a = x_a
      @stream_symbol = i
    end

    attr_reader :event_id, :payload_a, :stream_symbol

    def touched?
      @is_touched
    end

    def touch!
      @is_touched = true
      self
    end

    Event_ID___ = -> do
      d = 0
      -> { d += 1 }
    end.call
  end

  module InstanceMethods

    extend Callback_::Lib_::Let[]::ModuleMethods

    include Callback_::Lib_::Class[]::Creator::InstanceMethods

    let :meta_hell_anchor_module do ::Module.new end

    counter = 0

    let :klass do                 # working in conjunction w/ `inside` below,
      blk = inside                # make a Callback empowered class and nerk it
      kls = Digraph_TestSupport.const_set :"KLS_#{ counter += 1 }", ::Class.new
      kls.class_exec do
        Callback_[ self, :employ_DSL_for_digraph_emitter ]
        public :call_digraph_listeners  # [#002] public for testing

        define_method :build_digraph_event, B_D_E___

        class_exec(& blk ) if blk
      end
      kls
    end

    let :emitter do klass.new end

    def inside                    # the inside def dsl-ish part of a klass
    end
  end
end
