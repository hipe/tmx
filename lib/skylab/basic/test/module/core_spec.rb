require_relative '../test-support'

module Skylab::Basic::TestSupport::Module

  ::Skylab::Basic::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  Basic_ = Basic_

  describe "[ba] Module" do

    context "value via relative path" do

      it "loads" do
        Basic_::Module
      end

      it "ok" do
        mod = subject Basic_::Module, '..'
        mod.should eql Basic_
      end

      it "when you dotdot above a toplevel path - nil" do
        mod = subject ::Skylab, '..'
        mod.should be_nil
      end

      def subject mod, path
        Basic_::Module.value_via_relative_path mod, path
      end
    end

    it "Mutex" do

      module Zinger

        @a = []

        class << self
          attr_reader :a
        end

        define_singleton_method :push, Basic_::Module.mutex( -> x do
          @a <<  :"_#{ x }_"
        end )

      end

      Zinger.push :x
      Zinger.a.should eql %i( _x_ )
      _rx = /\bmodule mutex failure .+\bZinger\b/
      -> do
        Zinger.push :y
      end.should raise_error ::RuntimeError, _rx

    end
  end
end
