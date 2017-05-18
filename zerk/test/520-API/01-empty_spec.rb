require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] 0 - the empty ACS" do

    TS_[ self ]
    use :my_API

    it "builds" do
      build_root_ACS
    end

    context "call it with nothing" do

      call_by do
        call  # #test-01
      end

      it "results in a qualified knownness of the root ACS" do
        qk = root_ACS_result
        qk.value.hello.should eql :_emtpy_guy_
      end

      it "(emits nothing)" do
        expect_no_emissions
      end
    end

    context "call it with something" do

      call_by do
        call :something  # #test-02
      end

      it "fails" do
        fails
      end

      it "emits (with semi-nonsensical messasage)" do

        _be_thing = be_emission_ending_with :no_such_association do |ev|
          _ = black_and_white ev
          _.should eql "no such association 'something', expecting {}"
        end

        only_emission.should _be_thing
      end
    end

    def subject_root_ACS_class
      Remote_fixture_top_ACS_class[ :Class_01_Empty ]
    end
  end
end
