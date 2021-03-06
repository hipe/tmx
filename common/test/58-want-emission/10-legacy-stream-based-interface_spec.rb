require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] want emission - legacy stream-based interface" do

    # NOTE - reading tests that test libraries intended to be used for tests
    # is always confusing, but fortunately our naming conventions help
    # mitgate the problem somewhat:
    #
    #  • a method name (of ours) has *no* leading *nor* trailing underscores
    #    IFF it is a public API method [#bs-028] and
    #
    #   • we are only testing public API methods here (as is our custom) and
    #
    #   • the methods (of ours) that we use to assist in these tests are
    #     never public API methods so their names will either start or end
    #     with an underscore based on whether they are defined in this file
    #     or (what words out to be) a nearby one, respectively.
    #
    # as such; if the method has no leading underscores it's the one being
    # tested. otherwise it's a method assisting in the test. whew!

    TS_[ self ]
    use :memoizer_methods
    use :want_emission_meta
    use :want_emission

    def _expev_fail msg  # "trap" these ("crude") kinds of failures  BE CAREFUL

      ( @_fail_log ||= [] ).push msg

      false
    end

    it "when had one and expect none" do

      send_potential_event_ :bizzie, :bazzie do
        :_no_see_fake_event_
      end

      want_no_events

      want_lone_failure_ 'expected no more events, had [:bizzie, :bazzie]'
    end

    it "when had none and expect one" do

      event_log.handle_event_selectively  # kick it (see [#065.B])

      want_one_event :wazlow

      want_lone_failure_ "expected another event, had none"
    end

    context "(trap calls to quickie's fails - tests quickie only but etc..)" do

      def quickie_fail_with_message_by & p  # override internal API method

        _ = p.call

        _expev_fail _

        true  # only to work under r.s
      end

      it %(doesn't match the trilean) do  # :#coverpoint1.1

        _send_potential_OK_event_on_channel_x_y

        _em = want_not_OK_event :y

        _ = "expected event's `ok` value to be negative, was true"

        want_lone_failure_ _

        want_OK_emission_ _em
      end

      it "does match the trilean" do

        _send_potential_not_OK_event_on_channel_x_y

        _em = want_not_OK_event :y

        want_nothing_failed_

        want_not_OK_emission_ _em
      end

      it "doesn't match the TCS" do

        _send_potential_OK_event_on_channel_x_y

        _em = want_event :z

        want_lone_failure_ "expected `z` event, had `y`"

        want_OK_emission_ _em
      end

      it "does match the TCS" do

        _send_potential_OK_event_on_channel_x_y

        _em = want_event :y

        want_nothing_failed_

        want_OK_emission_ _em
      end

      it "doesn't match string message" do

        _send_potential_neutral_event_on_channel_x_y

        _em = want_neutral_event :y, 'shimmy'

        want_lone_failure_ 'expected "shimmy", had "i am a neutral event"'

        want_neutral_emission_ _em
      end

      it "does match string message" do

        _send_potential_not_OK_event_on_channel_x_y

        _em = want_not_OK_event :y, "i am a failure event"

        want_nothing_failed_

        want_not_OK_emission_ _em
      end

      it "doesn't match message via regexp" do

        _send_potential_neutral_event_on_channel_x_y

        _em = want_neutral_event :y, /\AI am a neutral event\z/

        _ = 'did not match /\AI am a neutral event\z/ - "i am a neutral event"'

        want_lone_failure_ _

        want_neutral_emission_ _em
      end

      it "does match message via regexp" do

        _send_potential_neutral_event_on_channel_x_y

        _em = want_neutral_event :y, /\AI am a neutral event\z/i

        want_nothing_failed_

        want_neutral_emission_ _em
      end

      def _send_potential_not_OK_event_on_channel_x_y

        send_potential_event_ :x, :y do
          self.NOT_OK_EVENT_
        end
        NIL_
      end

      def _send_potential_neutral_event_on_channel_x_y

        send_potential_event_ :x, :y do
          self.NEUTRAL_EVENT_
        end
        NIL_
      end

      def _send_potential_OK_event_on_channel_x_y

        send_potential_event_ :x, :y do
          self.OK_EVENT_
        end
        NIL_
      end
    end
  end
end
# #tombstone - old expect event (commit previous to this one)
