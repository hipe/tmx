require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity meta-property errors" do

    context "there are times when given the syntax you create" do

      before :all do

        MPE_Extmod = Subject_[][ -> do

          o :meta_property, :aruty

        end ]

      end

      context "a 'def' or 'property' is expected at the end of the input" do

        it "in 'o'" do
          -> do
            class MPE_EOI
              MPE_Extmod[ self, :aruty, :whatever ]
            end
          end.should raise_expected_method_definition_error
        end

        it "in '[]'" do
          -> do
            class MPE_EOI_B
              MPE_Extmod[ self, -> do
                o :aruty, :whatever
              end ]
            end
          end.should raise_expected_method_definition_error
        end

        def raise_expected_method_definition_error
          raise_error ::ArgumentError,
            /\bexpected method definition at end of iambic input\b/
        end
      end

      it "a value is expected for a meta-property being used" do
        -> do
          class MPE_EOI_X
            MPE_Extmod[ self, :aruty ]
          end
        end.should raise_expecting_value_for_aruty
      end

      def raise_expecting_value_for_aruty
        raise_error ::ArgumentError, /\bexpecting a value for 'aruty'/
      end

      it "a strange token while mid-property whines" do
        -> do
          class MPE_EOI_DURGY
            MPE_Extmod[ self, :aruty, :whatever, :durgy ]
          end
        end.should raise_error ::ArgumentError,
          /\bexpected 'property' not 'durgy'/
      end
    end
  end
end
