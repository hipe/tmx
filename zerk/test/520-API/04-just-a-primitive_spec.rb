require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - just a primitive" do

    TS_[ self ]
    use :my_API

    it "builds" do
      build_root_ACS
    end

    context "empty call from beginning - result is qk of top ACS" do

      call_by do
        call  # #test-01
      end

      it "no events" do
        want_no_emissions
      end

      it "ok" do
        qk = root_ACS_result
        qk.is_known_known or fail
        qk.association.model_classifications.looks_compound or fail
        expect( qk.value.hello ).to eql :_hi_
      end
    end

    context "first guy not found" do

      call_by do
        call :wazoo  # #test-02
      end

      it "fails" do
        fails
      end

      it "emits (says \"expecting ..\")" do

        _be_this = be_emission(
          :error, :no_such_association,
        ) do |ev|
          _ = black_and_white ev
          expect( _ ).to eql "no such association 'wazoo', expecting 'file_name'"
        end

        expect( only_emission ).to _be_this
      end
    end

    context "if the call \"lands on\" the primitivesque" do

      call_by do
        o = build_root_ACS
        o.set_file_nerm :_xXx_
        @root_ACS = o
        call :file_name  # #test-07
      end

      it "emits nothing" do
        want_no_emissions
      end

      it "result is a qk about the component" do
        qk = root_ACS_result
        qk.is_known_known or fail
        expect( qk.value ).to eql :_xXx_
        expect( qk.association.name.as_variegated_symbol ).to eql :file_name
      end
    end

    context "primitivesque then \"bad\" value - component must emit" do

      call_by do
        call :file_name, '/'  # #test-10
      end

      it "fails" do
        fails
      end

      it "emits" do

        _be_this = be_emission(
          :error, :expression, :invalid_value
        ) do |y|
          expect( y ).to eql [ "paths can't be absolute - \"/\"" ]
        end

        expect( only_emission ).to _be_this
      end
    end

    context "primitivesque then \"good\" value (but nothing else..)" do

      call_by do
        call :file_name, 'hi'  # #test-11
      end

      it "value is written" do
        _o = root_ACS
        expect( _o.read_file_nerm ).to eql 'hi'
      end

      it "event message is suitable for outputting to UI" do

        _be_this = be_emission(
          :info, :set_leaf_component,
        ) do |ev|
          expect( black_and_white ev ).to eql 'set file name to "hi"'
        end

        expect( only_emission ).to _be_this
      end
    end

    def subject_root_ACS_class
      Remote_fixture_top_ACS_class[ :Class_04_Just_a_Primitive ]
    end
  end
end
