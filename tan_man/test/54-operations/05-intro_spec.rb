require_relative '../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - intro" do

    TS_[ self ]

    it "the API is called with `call` - the empty call reports as error" do
      call_API
      expect_not_OK_event :no_such_action, "no such action - (ick nil)"
      expect_fail
    end

    it "called with a strange name is a soft error" do
      call_API :wazii, :wazoo
      expect_not_OK_event :no_such_action, "no such action - (ick :wazii)"
      expect_fail
    end

    it "xtra tokens on a ping" do

      call_API :ping, :wahootey

      _ = 'unrecognized (plural_noun [1, :attribute]) (and_ ["(ick :wahootey)"])'

      __ = "unrecognized attribute :wahootey"

      _em = expect_not_OK_event :error, _

      ev = _em.cached_event_value.to_event

      :extra_properties == ev.terminal_channel_symbol or fial

      black_and_white( ev ).should eql __

      expect_fail
    end

    it "sing sing sing to me" do
      call_API :ping
      expect_neutral_event :ping, "hello from tan man."
      expect_no_more_events
      @result.should eql :hello_from_tan_man
    end
  end
end
