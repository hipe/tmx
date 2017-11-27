require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] callback tree - host " do

    context "one" do

      before :all do

        class X_ct_hs_Mazlow
          Home_::CallbackTree::Host[ self ]
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
        expect( X_ct_hs_Mazlow ).to be_const_defined :Common_Tree__
      end

      it "builds the thing" do
        maz = X_ct_hs_Mazlow.new
        expect( maz ).to be_instance_variable_defined :@callbacks
      end

      it "can get busy" do
        maz = X_ct_hs_Mazlow.new ; y = z = nil
        maz.add_pow_listener -> x { y = x }
        maz.add_pow_listener -> x { z = x }
        r = maz.pow :hi
        expect( r ).to be_nil
        expect( y ).to eql :hi ; expect( z ).to eql :hi
      end
    end
  end
end
