require_relative '../../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] operation - non-proclike" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event
    use :expect_root_ACS

    it "missing required args raises semantic arg error" do

      _s = "'zoof' is missing required parameters 'foo' and 'quux'."

      begin
        call_ :zoof
      rescue Home_::MissingRequiredParameters => e
      end

      e.message.should eql _s
    end

    context "supply the required args" do

      call_by_ do
        call_ :zoof, :foo, :_hi_, :quux, :_hey_
      end

      it "emits business" do

        _be_this = be_emission_ending_with :k do |y|
          y.should eql [ '(highlight "k.")' ]
        end

        only_emission.should _be_this
      end

      it "results in business" do

        _x = root_ACS_result
        _x.should eql [ :_hi_, :_yoohoo_, :_hey_ ]
      end
    end

    def expression_agent_for_expect_event
      codifying_expag_
    end

    def subject_root_ACS_class
      Fixture_top_ACS_class[ :Class_43_Non_ProcLike ]
    end
  end
end
