require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Boxxy

  ::Skylab::MetaHell::TestSupport[ Boxxy_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  MetaHell = ::Skylab::MetaHell

  module ModuleMethods
    include MetaHell::Klass::Creator::ModuleMethods
  end

  module InstanceMethods
    extend MetaHell::Let
    include MetaHell::Klass::Creator::InstanceMethods

    last_num = 0

    let :meta_hell_anchor_module do
      o = ::Module.new
      Boxxy_TestSupport.const_set "MOD_#{ last_num += 1 }", o
      o
    end
  end
end
