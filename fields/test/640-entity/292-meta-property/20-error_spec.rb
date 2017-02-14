require_relative '../../../test-support'

Skylab::Brazen::TestSupport.lib_( :entity ).require_common_sandbox

module Skylab::Brazen::TestSupport::Entity_Sandbox

  describe "[br] entity - concerns - meta-property - errors" do

    context "there are times when given the syntax you create" do

      before :all do

        MPE_Extmod = Subject_[].call do

          o :meta_property, :aruty

        end
      end

      context "a 'def' or 'property' is expected at the end of the input" do

        it "in `[]`" do

          begin
            class MPE_EOI
              MPE_Extmod[ self, :aruty, :whatever ]
            end
          rescue Home_::ArgumentError => e
          end

          e.message.should _be_same
        end

        it "in 'o'" do
          begin
            class MPE_EOI_B
              MPE_Extmod.call self do
                o :aruty, :whatever
              end
            end
          rescue Home_::ArgumentError => e
          end

          e.message.should _be_same
        end

        def _be_same
          match %r(\bproperty or metaproperty never received a name - \(aruty = 'whatever')
        end
      end
    end
  end
end
