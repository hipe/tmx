require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Klass::Creator
  ::Skylab::MetaHell::TestSupport::Klass[ self ]

  Creator_TestSupport = self
  MetaHell = MetaHell # for here


  module ModuleMethods
    def borks msg
      # it ( "fuck my life" ) { subject.call }
      specify { should( raise_error msg ) }
    end
    def doing &f
      let :subject do
        -> { instance_exec(& f) } # yeah, wow
      end
    end
    def snip &f
      let :klass do
        ::Class.new.class_eval do
          extend MetaHell::Let # compat
          extend MetaHell::Klass::Creator
          let( :meta_hell_anchor_module ) { ::Module.new }
          class_exec(& f) if f
          self
        end
      end
    end
  end


  module InstanceMethods
    extend MetaHell::Let
  end
end
