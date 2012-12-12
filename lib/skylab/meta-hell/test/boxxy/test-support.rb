require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Boxxy
  ::Skylab::TestSupport::Regret[ Boxxy_TestSupport = self ]

  MetaHell = ::Skylab::MetaHell

  module ModuleMethods
    include MetaHell::Klass::Creator::ModuleMethods

  end


  module InstanceMethods
    extend MetaHell::Let
    include MetaHell::Klass::Creator::InstanceMethods

    let( :meta_hell_anchor_module ) do
      o = ::Module.new
      o.singleton_class.send( :define_method, :to_s ) { "Wahoo" }
      o
    end
  end
end
