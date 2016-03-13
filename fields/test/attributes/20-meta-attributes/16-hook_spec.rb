require_relative '../../test-support'

module Skylab::Fields::TestSupport

  TS_.require_ :attributes_meta_attributes  # #[#017]
  module Attributes::Meta_Attributes

    TS_.describe "[fi] attributes - meta-attributes - hook" do

      TS_[ self ]
      use :memoizer_methods
      Attributes::Meta_Attributes[ self ]

      context "intro" do

        shared_subject :entity_class_ do

          class X_Hook_A

            attrs = Subject_module_[].call(
              error: :hook,
            )

            attrs.define_methods self

            self
          end
        end

        it "write with `on__x__`" do

          o = build_empty_entity_
          o.on__error__

          o.instance_variable_defined?( :@error ) or fail
          o.instance_variable_get( :@error ) and fail
        end

        it "\"read\" with `receive__x__`" do

          o = build_empty_entity_

          yes = nil
          o.on__error__ do |k|
            yes = k
          end

          x = o.receive__error__ :_hi_

          x.should be_nil

          yes.should eql :_hi_
        end
      end
    end
  end
end
