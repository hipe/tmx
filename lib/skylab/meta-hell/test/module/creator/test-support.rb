require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Module::Creator

  ::Skylab::MetaHell::TestSupport::Module[ TS_ = self ]

  include Constants

  module ModuleMethods
    include Constants
    def snip &f
      let :klass do
        ::Class.new.class_eval do
          extend MetaHell_::Let  # #comport
          extend MetaHell_::Module::Creator
          let( :meta_hell_anchor_module ) { ::Module.new }
          class_exec(& f) if f
          self
        end
      end
    end
  end
end
