require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - pop intro" do

    TS_[ self ]
    use :my_API

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
        expect( vp.V ).to eql 'like'
        expect( vp.O ).to be_nil
        expect( o.SUBJ ).to eql 'you'
      end

      it "result is last qk of thing - etc" do
        qk = root_ACS_result
        expect( qk.value ).to eql 'you'
        expect( qk.association.name_symbol ).to eql :subject
      end
    end

    def subject_root_ACS_class
      Remote_fixture_top_ACS_class[ :Class_41_Sentence ]
    end
  end
end
