require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] entity - concerns - meta-property - errors" do

    TS_[ self ]
    use :memoizer_methods
    use :entity

    context "there are times when given the syntax you create" do

      shared_subject :_extension_module do

        X_e_mp_e_Extmod = Entity.lib.call do

          o :meta_property, :aruty

        end
      end

      context "a 'def' or 'property' is expected at the end of the input" do

        it "in `[]`" do

          _extension_module

          begin
            class X_e_mp_e_EOI
              X_e_mp_e_Extmod[ self, :aruty, :whatever ]
            end
          rescue Home_::ArgumentError => e
          end

          expect( e.message ).to _be_same
        end

        it "in 'o'" do

          _extension_module

          begin
            class X_e_mp_e_EOI_B
              X_e_mp_e_Extmod.call self do
                o :aruty, :whatever
              end
            end
          rescue Home_::ArgumentError => e
          end

          expect( e.message ).to _be_same
        end

        def _be_same
          match %r(\bproperty or metaproperty never received a name - \(aruty = 'whatever')
        end
      end
    end
  end
end
