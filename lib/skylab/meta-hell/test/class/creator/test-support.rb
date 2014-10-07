require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Class::Creator

  ::Skylab::MetaHell::TestSupport::Class[ TS_ = self ]

  include CONSTANTS

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
          extend MetaHell_::Let  # #comport
          extend MetaHell_::Class::Creator
          let( :meta_hell_anchor_module ) { ::Module.new }
          class_exec(& f) if f
          self
        end
      end
    end
  end


  module InstanceMethods
    include CONSTANTS
    extend MetaHell_::Let
  end
end
