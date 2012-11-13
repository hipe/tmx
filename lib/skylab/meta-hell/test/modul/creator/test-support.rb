require_relative '../test-support'

module ::Skylab::MetaHell::TestSupport::Modul::Creator
  (Parent_ = ::Skylab::MetaHell::TestSupport::Modul)[ self ] # #ts-002
  Creator_TestSupport = self # courtesy

  CONSTANTS = Parent_::CONSTANTS

  include CONSTANTS # for the spec

  module ModuleMethods
    include CONSTANTS
    def snip &f
      let :klass do
        ::Class.new.class_eval do
          extend MetaHell::Let # compat
          extend MetaHell::Modul::Creator
          let( :meta_hell_anchor_module ) { ::Module.new }
          class_exec(& f) if f
          self
        end
      end
    end
  end
end
