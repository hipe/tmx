require_relative '../test-support'
require 'skylab/meta-hell/core'

module Skylab::PubSub::TestSupport::Emitter
  ::Skylab::PubSub::TestSupport[ self ] # #regret

  module CONSTANTS
    MetaHell = ::Skylab::MetaHell
    PubSub = ::Skylab::PubSub
  end

  include CONSTANTS                            # ** so we can use them inside
                                               #     the moduls omfg!! **
  module ModuleMethods
    include CONSTANTS
    include MetaHell::Klass::Creator::ModuleMethods

  end

  module InstanceMethods
    include CONSTANTS                          # so we can use the below consts
    extend MetaHell::Let::ModuleMethods        # rspec defines the inst. meths

    include MetaHell::Klass::Creator::InstanceMethods

    let( :meta_hell_anchor_module ) { ::Module.new }

  end
end
