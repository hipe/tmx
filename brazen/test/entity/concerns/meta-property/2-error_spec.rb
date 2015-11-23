require_relative '../../../test-support'

Skylab::Brazen::TestSupport.lib_( :entity ).require_common_sandbox

module Skylab::Brazen::TestSupport::Entity_Sandbox

  describe "[br] entity meta-property errors" do

    context "there are times when given the syntax you create" do

      before :all do

        MPE_Extmod = Subject_[].call do

          o :meta_property, :aruty

        end
      end

      context "a 'def' or 'property' is expected at the end of the input" do

        it "in `[]`" do
          -> do
            class MPE_EOI
              MPE_Extmod[ self, :aruty, :whatever ]
            end
          end.should raise_expected_method_definition_error
        end

        it "in 'o'" do
          -> do
            class MPE_EOI_B
              MPE_Extmod.call self do
                o :aruty, :whatever
              end
            end
          end.should raise_expected_method_definition_error
        end

        def raise_expected_method_definition_error
          raise_error ::ArgumentError,
            /\bproperty or metaproperty never received a name - \(aruty = 'whatever'/
        end
      end
    end
  end
end
