require_relative 'test-support'

module Skylab::TanMan::TestSupport::API

  describe "[tm] API" do

    TanMan_::TestSupport::TestLib_::API_expect[ self ]

    extend TS_

    it "the API is called with `call` - the empty call reports as error" do
      call_API
      expect_not_OK_event :no_such_action, "no such action - ''"
      expect_failed
    end

    it "called with a strange name is a soft error" do
      call_API :wazii, :wazoo
      expect_not_OK_event :no_such_action, "no such action - wazii"
      expect_failed
    end

    it "xtra tokens on a ping" do
      call_API :ping, :wahootey
      ev = expect_not_OK_event :extra_properties,
        'unrecognized (plural_noun ["property", 1]) (and_ ["(ick :wahootey)"])'
      black_and_white( ev ).should eql "unrecognized property :wahootey"
      expect_failed
    end

    it "sing sing sing to me" do
      call_API :ping
      expect_neutral_event :ping, "hello from tan man."
      expect_no_more_events
      @result.should eql :hello_from_tan_man
    end

    context "kernel" do

      it "a minimal properties stack integration test" do
        subject_API.application_kernel.
          kernel_property_value( :local_conf_maxdepth ).
            should eql 1
      end
    end
  end
end
