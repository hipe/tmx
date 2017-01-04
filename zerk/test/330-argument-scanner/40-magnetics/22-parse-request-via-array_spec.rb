require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] argument scanner - magnetics - parse request via.." do

    TS_[ self ]

    it "one that doesn't wrap says it doesn't wrap" do

      _subj = _one_that
      _subj.successful_result_will_be_wrapped || fail
    end

    it "one that does wrap says it does wrap" do

      _subj = _one_that :must_be_trueish
      _subj.successful_result_will_be_wrapped && false
    end

    def _one_that * sym_a
      _subject_module[ sym_a ]
    end

    def _subject_module
      Home_::ArgumentScanner::Magnetics::ParseRequest_via_Array
    end
  end
end
