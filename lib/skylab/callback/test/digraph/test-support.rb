require_relative '../test-support'
require 'skylab/meta-hell/core'

module Skylab::Callback::TestSupport::Emitter

  ::Skylab::Callback::TestSupport[ Emitter_TestSupport = self ] # #regret

  module CONSTANTS
    MetaHell = ::Skylab::MetaHell
    Callback = ::Skylab::Callback
    TestSupport = ::Skylab::TestSupport        # for the love of god man
  end

  include CONSTANTS                            # ** so we can use them inside
                                               #     the moduls omfg!! **

  extend TestSupport::Quickie

  module ModuleMethods
    include CONSTANTS
    include MetaHell::Class::Creator::ModuleMethods

    def inside &b                 # define the dsl-ish klass body to be somthing
      b or fail 'give a block'    # other than nothing (below)
      define_method :inside do b end
    end

    def memoize name, func
      define_method name, & MetaHell::FUN.memoize[ func ]
      nil
    end
  end

  module InstanceMethods
    include CONSTANTS                          # so we can use the below consts
    extend MetaHell::Let::ModuleMethods        # rspec defines the inst. meths

    include MetaHell::Class::Creator::InstanceMethods

    let :meta_hell_anchor_module do ::Module.new end

    counter = 0

    let :klass do                 # working in conjunction w/ `inside` below,
      blk = inside                # make a Callback empowered class and nerk it
      kls = Emitter_TestSupport.const_set "KLS_#{ counter += 1 }", ::Class.new
      kls.class_exec do
        Callback[ self, :employ_DSL_for_emitter ]
        public :emit # [#ps-002] public for testing
        class_exec(& blk ) if blk
      end
      kls
    end

    let :emitter do klass.new end

    def inside                    # the inside def dsl-ish part of a klass
    end
  end
end
