require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - non-proclike operation" do

    TS_[ self ]
    use :my_API

    it "missing required args - raises arg. error (cp)" do

      _s = "'zoof' is missing required parameters 'foo' and 'quux'."

      begin
        call :zoof  # #test-03
      rescue Home_::ACS_::MissingRequiredParameters => e
      end

      expect( e.message ).to eql _s
    end

    context "extra args" do

      call_by do
        call :zoof, :foo, :_hi_, :quux, :_hey_, :extra  # #test-03
      end

      it "fails" do
        fails
      end

      it "emits (in contrast to counterpart in [ac])" do
        expect( only_emission ).to be_emission_ending_with past_end_of_phrase_
      end
    end

    context "supply the required args" do

      call_by do
        call :zoof, :foo, :_hi_, :quux, :_hey_  # #test-05
      end

      it "emits business (cp)" do

        _be_this = be_emission_ending_with :k do |y|
          expect( y ).to eql [ '** k. **' ]
        end

        expect( only_emission ).to _be_this
      end

      it "results in business (cp)" do
        _x = root_ACS_result
        expect( _x ).to eql [ :_hi_, :_yoohoo_, :_hey_ ]
      end
    end

    def subject_root_ACS_class
      Remote_fixture_top_ACS_class[ :Class_43_Non_Proclike ]
    end
  end
end
