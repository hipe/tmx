require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Boxxy

  ::Skylab::MetaHell::TestSupport[ TS_ = self ]

  include CONSTANTS

  MetaHell = MetaHell

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  module ModuleMethods
    include MetaHell::Class::Creator::ModuleMethods
  end

  module InstanceMethods
    extend MetaHell::Let
    include MetaHell::Class::Creator::InstanceMethods

    last_num = 0

    let :meta_hell_anchor_module do
      o = ::Module.new
      TS_.const_set "MOD_#{ last_num += 1 }", o
      o
    end
  end
end
