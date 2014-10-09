require_relative 'test-support'

module Skylab::Brazen::TestSupport::Model::Entity

  describe "[br] entity- can be used usefully not just for app actions but" do

    extend TS_

    context "for small ad-hoc agents too, for e.g when required properties" do

      with_class do
        class E__Small_Agent_With_Required_Properties
          attr_reader :bx
          Subject_[][ self,
            :required, :property, :foo,
            :required, :property, :bar,
            :properties, :bif, :baz ]

          def prcss_iambic_passively_via_args a
            super
            notificate :iambic_normalize_and_validate
          end

        private
          def actual_property_box
            @bx ||= Brazen_::Box_.new
          end
          self
        end
      end

      it "are ok, it works (note optional fields are not required)" do
        o = subject_class.new.send :with, :foo, :a, :bar, :b, :baz, :c
        o.bx.at( :foo, :bar, :baz ).should eql [ :a, :b, :c ]
      end

      it "missing, throws argument error with msg with same template as app!" do
        -> do
          subject_class.new.send :with, :bif, :x, :baz, :y
        end.should raise_error ::ArgumentError, "missing required properties 'foo' and 'bar'"
      end
    end

    context "for small, ad-hoc agents that want defaulting" do

      with_class do
        class E__Small_Agent_With_Defaults
          attr_reader  :bx

          Subject_[][ self, -> do
            o :default, :yay, :property, :foo
          end ]

          def prcss_iambic_passively_via_args a
            super
            notificate :iambic_normalize_and_validate
          end

          def actual_property_box
            @bx ||= Brazen_::Box_.new
          end

          self
        end
      end

      it "(with defaulting)" do
        o = subject_class.new.send :with
        o.bx.fetch( :foo ).should eql :yay
      end

      it "(without defaulting)" do
        o = subject_class.new.send :with, :foo, :bar
        o.bx.fetch( :foo ).should eql :bar
      end
    end
  end
end
