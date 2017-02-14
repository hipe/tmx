require_relative '../../test-support'

module Skylab::Fields::TestSupport

  TS_.require_ :attributes_meta_attributes  # #[#017]
  module Attributes::Meta_Attributes

    TS_.describe "[fi] attributes - meta-attributes - list" do

      TS_[ self ]
      use :memoizer_methods
      Attributes::Meta_Attributes[ self ]

      context "(context)" do

        shared_subject :entity_class_ do

          class X_List_A

            attrs = Subject_module_[].call(
              topping: :list,
            )

            attrs.define_methods self

            self
          end
        end

        it "loads" do
          entity_class_
        end

        it "you don't get a reader - keep it orthoganal and simple" do

          entity_class_.instance_method( :topping ).arity.should eql 1
        end

        it "ok" do

          o = build_empty_entity_
          o.topping :sprinkles
          o.topping :sparkles
          o.instance_variable_get( :@topping ).should eql [ :sprinkles, :sparkles ]
        end
      end
    end
  end
end
