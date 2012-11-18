require_relative '../test-support'

module ::Skylab::MetaHell::TestSupport::Modul::Creator
  ::Skylab::MetaHell::TestSupport::Modul[ self ] # #regret
  Creator_TestSupport = self # courtesy

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
