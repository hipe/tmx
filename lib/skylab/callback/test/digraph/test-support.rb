require_relative '../test-support'

module Skylab::Callback::TestSupport::Digraph

  ::Skylab::Callback::TestSupport[ Digraph_TestSupport = self ] # #regret

  include CONSTANTS

  Callback = Callback

  Callback::Lib_::Quickie[ self ]

  module ModuleMethods
    include CONSTANTS
    include Callback::Lib_::Class[]::Creator::ModuleMethods

    def inside &b                 # define the dsl-ish klass body to be somthing
      b or fail 'give a block'    # other than nothing (below)
      define_method :inside do b end
    end

    def memoize name, func
      define_method name, & Callback::Lib_::Memoize[ func ]
      nil
    end
  end

  module InstanceMethods

    extend Callback::Lib_::Let[]::ModuleMethods

    include Callback::Lib_::Class[]::Creator::InstanceMethods

    let :meta_hell_anchor_module do ::Module.new end

    counter = 0

    let :klass do                 # working in conjunction w/ `inside` below,
      blk = inside                # make a Callback empowered class and nerk it
      kls = Digraph_TestSupport.const_set "KLS_#{ counter += 1 }", ::Class.new
      kls.class_exec do
        Callback[ self, :employ_DSL_for_digraph_emitter ]
        public :call_digraph_listeners  # [#002] public for testing
        class_exec(& blk ) if blk
      end
      kls
    end

    let :emitter do klass.new end

    def inside                    # the inside def dsl-ish part of a klass
    end
  end
end
