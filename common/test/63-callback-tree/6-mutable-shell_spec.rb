require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] callback tree - mutable shell" do

    context "one" do

      before :all do

        class X_ct_ms_WapZazzle
          Home_::CallbackTree::Host[ self ]
          spec = build_mutable_callback_tree_specification
          spec.default_pattern :callback
          spec << :wiff
          spec << :waff
          spec.end
          attr_reader :callbacks
        end
      end

      it "build yielder for (and test new 'callback' pattern)" do
        cb = X_ct_ms_WapZazzle.new.callbacks
        y = cb.build_yielder_for :waff ; z = nil
        cb.set_callback :waff, -> x { z = x }
        y << :neet
        expect( z ).to eql :neet
      end

      it "mutable shell builds" do
        X_ct_ms_WapZazzle.new.callbacks.build_mutable_shell
      end

      it "mutable shell single arg proc form" do
        same do |cond|
          cond.wiff -> x { @y = x }
        end
      end

      it "mutable shell block form" do
        same do |cond|
          cond.wiff { |x| @y = x }
        end
      end

      def same
        cb = X_ct_ms_WapZazzle.new.callbacks
        cond = cb.build_mutable_shell
        yield cond
        cb.call_callback :wiff, :merp
        expect( @y ).to eql :merp
      end
    end
  end
end
