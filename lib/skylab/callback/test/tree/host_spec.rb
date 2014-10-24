require_relative 'test-support'

module Skylab::Callback::TestSupport::Tree

  describe "[gv] lib- callbacks-tree: host" do

    context "one" do

      before :all do

        class Mazlo
          Callback_::Tree::Host[ self ]
          spec = build_mutable_callback_tree_specification
          spec.default_pattern :listeners
          spec << :pow
          spec.end

          def initialize
            super
          end

          def add_pow_listener p
            @callbacks.add_listener :pow, p ; nil
          end

          def pow x
            @callbacks.call_listeners :pow do x end
          end
        end
      end

      it "creates the thing" do
        Mazlo.should be_const_defined :Callback_Tree__
      end

      it "builds the thing" do
        maz = Mazlo.new
        maz.should be_instance_variable_defined :@callbacks
      end

      it "can get busy" do
        maz = Mazlo.new ; y = z = nil
        maz.add_pow_listener -> x { y = x }
        maz.add_pow_listener -> x { z = x }
        r = maz.pow :hi
        r.should be_nil
        y.should eql :hi ; z.should eql :hi
      end
    end
  end
end
