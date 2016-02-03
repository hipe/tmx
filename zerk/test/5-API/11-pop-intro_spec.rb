require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - pop intro" do

    TS_[ self ]
    use :API

    context "sic" do

      call_by do
        call(
          :verb_phrase,
            :verb, 'like',
          :subject, 'you',
        )
      end

      it "structure is right" do
        o = root_ACS
        vp = o.VP
        vp.V.should eql 'like'
        vp.O.should be_nil
        o.SUBJ.should eql 'you'
      end

      it "result is last qk of thing - etc" do
        qk = root_ACS_result
        qk.value_x.should eql 'you'
        qk.association.name_symbol.should eql :subject
      end
    end

    def subject_root_ACS_class
      Remote_fixture_top_ACS_class[ :Class_41_Sentence ]
    end
  end
end
