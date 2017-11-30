require_relative '../test-support'

module Skylab::Arc::TestSupport

  describe "[arc] operation - non-proclike" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event
    use :want_root_ACS

    it "missing required args raises semantic arg error" do

      _s = "'zoof' is missing required parameters 'foo' and 'quux'."

      begin
        call_ :zoof
      rescue Home_::MissingRequiredParameters => e
      end

      expect( e.message ).to eql _s
    end

    context "supply the required args" do

      call_by_ do
        call_ :zoof, :foo, :_hi_, :quux, :_hey_
      end

      it "emits business" do

        _be_this = be_emission_ending_with :k do |y|
          expect( y ).to eql [ '(highlight "k.")' ]
        end

        expect( only_emission ).to _be_this
      end

      it "results in business" do

        _x = root_ACS_result
        expect( _x ).to eql [ :_hi_, :_yoohoo_, :_hey_ ]
      end
    end

    def expression_agent_for_want_emission
      expag_for_codifying__
    end

    def subject_root_ACS_class
      Fixture_top_ACS_class[ :Class_43_Non_Proclike ]
    end
  end
end
