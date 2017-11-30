require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - primitive get and set" do

    # NOTE the implementation of and syntax for this used to have more
    # moving parts before we made the simplification illustrated in [#012].
    #
    # we used have what amounted to a somewhat redundant implementation
    # of something resembling "transitive operations" but only for
    # interfaces. now, interface-specifics are not allowed in ACS's,
    # and getters/setters are automatically part of a zerk-generated
    # API syntax.
    #
    # as such, this is now more redundant than it used to be with previous
    # test and so it is now subject to re-appropriation as may be desired.

    TS_[ self ]
    use :my_API

    context "several component association with proc-like models.." do

      context "get when not set" do

        call_by do
          call :shoestring_length  # #test-06
        end

        it "qk etc" do
          qk = root_ACS_result
          qk.is_known_known and fail
          expect( qk.association.name_symbol ).to eql :shoestring_length
        end
      end

      context "get when set" do

        call_by do
          @root_ACS = build_root_ACS
          @root_ACS.set_shoestring_length_ 123
          call :shoestring_length
        end

        it "ok" do
          expect( root_ACS_result.value ).to eql 123
        end
      end

      context "set when invalid" do

        call_by do
          call :shoestring_length, '98 degrees'  # #test-10
        end

        it "fails" do
          fails
        end

        it "emits" do

          _be_this = be_emission :error, :expression, :nope do | s_a |
            [ "doesn't look like integer: \"98 degrees\"" ]
          end

          expect( only_emission ).to _be_this
        end
      end

      context "set when valid" do

        call_by do
          call :shoestring_length, '98'  # #test-11
        end

        it "appears to work" do
          _qk = root_ACS_result
          expect( _qk.value ).to eql 98
        end

        it "worked" do
          expect( root_ACS.get_shoestring_length_ ).to eql 98
        end
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_22_Uggs ]
    end
  end
end
