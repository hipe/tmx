require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Modul end

module Skylab::MetaHell::TestSupport::Modul::Creator
  include( Up_ = ::Skylab::MetaHell::TestSupport ) # #constants

  Creator_TestSupport = self
  MetaHell = MetaHell # for here

  def self.extended mod
    mod.extend ModuleMethods
    mod.send :include, InstanceMethods
  end


  module ModuleMethods
    def snip &f
      let :klass do
        ::Class.new.class_eval do
          extend MetaHell::Let # compat
          extend MetaHell::Modul::Creator
          let( :meta_hell_anchor_module ) { ::Module.new }
          class_exec(& f)
          self
        end
      end
    end
  end


  module InstanceMethods
    extend MetaHell::Let

    let :o do
      klass.new
    end
  end
end
