require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Klass::Creator
  (Parent_ = ::Skylab::MetaHell::TestSupport::Klass)[ self ] # #ts-002, regret
  Creator_TestSupport = self # courtesy

  CONSTANTS = Parent_::CONSTANTS

  include CONSTANTS # for the spec

  module ModuleMethods
    include CONSTANTS
    def borks msg                  # this one is pretty but hard to debug
      specify { should( raise_error msg ) }
    end
    def borks_ msg                 # this one is easier to debug, but throws
      it( "fuck my life" ) { subject.call } # the exception w/o catching it
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
    include CONSTANTS
    extend MetaHell::Let
  end
end
