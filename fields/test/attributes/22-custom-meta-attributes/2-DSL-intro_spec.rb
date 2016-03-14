require_relative '../../test-support'

module Skylab::Fields::TestSupport

  TS_.require_ :attributes  # #[#017]
  module Attributes

    TS_.describe "[fi] attributes - meta-attributes - DSL experiment (P.o.C)" do

      TS_[ self ]
      use :memoizer_methods

      context "flag-based meta-attribute" do

        shared_subject :entity_class_ do

          class X_MA_DSL_E_A

            attrs = Subject_module_[].call(
              social_security_number: :highly_sensitive,
              last_name: nil,
            )

            attrs.define_meta_attribute :flag, :highly_sensitive

            ATTRIBUTES = attrs

            self
          end
        end

        it "loads" do
          entity_class_
        end

        it "is is" do
          _attrs.attribute( :social_security_number ).is_highly_sensitive or fail
        end

        it "isn't isn't" do
          _attrs.attribute( :last_name ).is_highly_sensitive and fail
        end
      end

      # (we will also likely implement & test a plain old valued meta-attribute)

      def _attrs
        entity_class_.const_get( :ATTRIBUTES, false )
      end
    end
  end
end
