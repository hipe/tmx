require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Class::Creator
  ::Skylab::MetaHell::TestSupport::Class[ self ] # #regret
  Creator_TestSupport = self # courtesy

  include CONSTANTS # for the spec

  module ModuleMethods
    include CONSTANTS
    def borks msg
      it "raises error with message - #{ msg }" do
        -> do
          subject.call
        end.should raise_error( msg )
      end
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
          extend MetaHell::Class::Creator
          let( :meta_hell_anchor_module ) { ::Module.new }
          class_exec(& f) if f
          self
        end
      end
    end
  end


  module InstanceMethods
    include CONSTANTS
    extend MetaHell::Let
  end
end
