require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Module::Core__

  ::Skylab::MetaHell::TestSupport::Module[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  MetaHell_ = MetaHell_

  describe "[mh] Module" do

    context "Resolve" do
      it "o" do
        mod = MetaHell_::Module::Resolve[ '..', MetaHell_::Module ]
        mod.should eql MetaHell_
      end

      it "when you dotdot above a toplevel path - nil" do
        mod = MetaHell_::Module::Resolve[ '..', Skylab ]
        mod.should be_nil
      end
    end

    it "Mutex" do

      module Zinger
        @a = []
        class << self ; attr_reader :a end
        define_singleton_method :push, MetaHell_::Module::Mutex[ -> x do
          @a <<  :"_#{ x }_"
        end ]
      end

      Zinger.push :x
      Zinger.a.should eql %i( _x_ )
      -> do
        Zinger.push :y
      end.should raise_error ::RuntimeError,
        /\bMutex failure .+\bZinger\b/

    end
  end
end
