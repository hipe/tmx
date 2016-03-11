require_relative '../../test-support'

module Skylab::Fields::TestSupport

  TS_.require_ :attributes_meta_attributes

  module Attributes::Meta_Attributes

    TS_.describe "[fi] attributes - meta-attributes - list" do

      TS_[ self ]
      use :memoizer_methods

      context "(context)" do

        shared_subject :_class do

          class X_List_A

            attrs = Subject_module_[].call(
              topping: :list,
            )

            attrs.define_methods self

            ATTRIBUTES = attrs

            self
          end
        end

        it "loads" do
          _class
        end

        it "you don't get a reader - keep it orthoganal and simple" do

          _class.instance_method( :topping ).arity.should eql 1
        end

        it "ok" do

          o = _build_empty
          o.topping :sprinkles
          o.topping :sparkles
          o.instance_variable_get( :@topping ).should eql [ :sprinkles, :sparkles ]
        end
      end

      def _build_empty
        _class.new
      end
    end
  end
end
