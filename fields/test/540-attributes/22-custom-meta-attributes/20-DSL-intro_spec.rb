require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] attributes - meta-attributes - DSL experiment (P.o.C)" do

    TS_[ self ]
    use :memoizer_methods
    use :attributes

      context "flag-based meta-attribute" do

        shared_subject :entity_class_ do

          class X_a_cma_DSL_A

            attrs = Attributes.lib.call(
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
          attribute_( :social_security_number ).is_highly_sensitive or fail
        end

        it "isn't isn't" do
          attribute_( :last_name ).is_highly_sensitive and fail
        end
      end

      # (we will also likely implement & test a plain old valued meta-attribute)

    # ==
    # ==
  end
end
