require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] custom meta associations! - DSL experiment (P.o.C)" do

    TS_[ self ]
    use :memoizer_methods
    use :attributes

      context "flag-based meta-attribute" do

        # what we do here is a proof-of-concept (perhaps a #feature-island) of:
        #
        #   A) how it's possible to define meta-associations thru a DSL
        #      (using the meta-meta-association grammar!) and B) it d
        #
        #   B) the fact that association definitions are evaluated lazily
        #      (note the meta-association is defined "after" it is used.)
        #
        # it's tracked with #[#002.C.4] in case we ever find a use for it
        #

        # specifically in the following example, we introduce a meta-
        # association called "highly sensitive". we define it as a flag.
        #
        # ("flag" is a built in meta-meta-association; perhaps the only one.)
        #
        # in the corresponding asset node, creating a flag-shaped meta-
        # association does things to every association that is associated
        # with the meta-association. whew!

        shared_subject :entity_class_ do

          class X_cma_DSL_A

            attrs = Attributes.lib.call(
              social_security_number: :highly_sensitive,
              last_name: nil,
            )

            ATTRIBUTES = attrs  # assign before below just to see what's going on better

            attrs.define_meta_association___ :highly_sensitive, :flag

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
