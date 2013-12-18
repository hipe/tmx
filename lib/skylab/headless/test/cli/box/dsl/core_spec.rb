require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Box::DSL

  describe "[hl] CLI box DSL" do

    extend TS__

    context "the empty class" do

      box_DSL_class :Yolanda do end

      it "0    no args - error / usage / invite" do
        invoke
        expect expecting_rx
        expect_usage_and_invited
      end

      it "1.1  funky action - e / u / i" do
        invoke 'jenkum'
        expect %r(\bthere is no "jenkum" action\. #{ expecting_rx.source })
        expect_usage_and_invited
      end

      self::EXPECTING_RX = /\bexpecting \{\}/

      self::USAGE_RX = /\Ausage: yerp yolanda \[<action>\] \[<args> \[\.\.\]\]\z/

      self::INVITE_RX = /\Ause yerp yolanda -h \[<action>\] for help\z/
    end

    context "with nothing but a method definition" do

      box_DSL_class :Beaglesworth do
        def yowzaa
          emit_info_line 'doofie'  # #todo:before-merge
          :koofie
        end
      end

      it "internally an action class is created - (..::Actions::Yowzaa)" do
        box_DSL_class::Actions::Yowzaa  # success is the absence of failure
      end

      it "the action object itself gives an option parser with a -h" do
        _client = box_action.client_services_for_bound_action_by_agent
        bound_action = box_DSL_class::Actions::Yowzaa.new _client
        op = bound_action.send :op  # the bound_action object has an option parser
        ( !! op ).should eql true
        op.top.list.length.should eql 1  # which has only 1 element
        op.top.list.first.short.first.should eql '-h'  # which is '-h'
        op.parse '--hel'
        a = bound_action.instance_variable_get QUEUE_IVAR__
        a.should be_nil
      end

      it "0    nothing - error / usage / invite" do
        invoke
        expect :styled, expecting_rx
        expect_usage_and_invited
      end

      it "1.1  invalid action - e / u / i" do
        invoke 'nonsense'
        expect :styled, %r(\bthere is no "nonsense" action. #{
          expecting_rx.source })
        expect_usage_and_invited
      end

      it "1.2  invalid option - e / u / i" do
        invoke '-x'
        expect "invalid option: -x"
        expect_usage_and_invited
      end

      it "2.1  unexpected arg - e / u / i" do
        invoke 'yowzaa', 'bing'
        expect "unexpected argument: \"bing\""
        expect_engaged_usage_and_invite
      end

      it "2.2  unexpected opt - e / u / i" do
        invoke 'yowzaa', '-x'
        expect "invalid option: -x"
        expect_engaged_usage_and_invite
      end

      def expect_engaged_usage_and_invite
        expect :styled, "usage: yerp beaglesworth yowzaa [-h]"
        expect :styled, "use yerp beaglesworth -h yowzaa for help"
        expect_failed
      end

      it "2.4  expected opt (help) - screen" do
        invoke 'yowzaa', '-h'
        expect_help_screen_for_yowzaa_child
      end

      def expect_help_screen_for_yowzaa_child
        expect_usage_line_ending_with 'beaglesworth yowzaa [-h]'
        expect_blank
        expect_header :options
        expect_normal_help_option_item
        expect_succeeded
      end

      def expect_normal_help_option_item
        expect %r(\A {2,}-h, --help {2,}this screen\z)
      end

      it "1.4  just `-h` - the big screen" do
        invoke '-h'
        expect_the_big_screen_is_ok
      end

      def expect_the_big_screen_is_ok
        expect :styled, usage_rx
        expect_blank
        expect_header :options
        expect_help_option_item_as_box
        expect_blank
        expect_header :action
        expect_child_node_item_for :yowzaa
        expect_blank
        expect_leading_help
        expect_succeeded
      end

      it "1.3  no args as expected - works" do
        invoke 'yowzaa'
        expect 'doofie'
        expect_no_more_serr_lines
        @result.should eql :koofie
      end

      self::EXPECTING_RX = /\bexpecting \{yowzaa\}/

      self::USAGE_RX = /\Ausage: yerp beaglesworth \[<action>\] \[<args> \[\.\.\]\]\z/

      self::INVITE_RX = /\Ause yerp beaglesworth -h \[<action>\] for help\z/

      def expect_help_option_item_as_box
        expect %r(\A {2,}-h, --help \[<sub-action>\] {2,}this screen#{
          } \[or sub-action help\]\z)
      end

      def expect_child_node_item_for i
        expect %r(.)
      end

      def expect_leading_help
        x = crunchify
        x.length.should eql 3
        x.shift.should eql 'use '
        x.pop.should eql ' for help on that action'
        xx = x.shift
        x.length.zero? or fail "huh? #{ x }"
        xx.pop.should eql "yerp beaglesworth -h <action>"
        xx.should eql %i( green )  # etc
      end
    end

    def expecting_rx
      self.class::EXPECTING_RX
    end

    def expect_usage_and_invited
      expect_usage
      expect_invite
      expect_failed
    end

    def expect_usage
      expect :styled, usage_rx
    end

    def usage_rx
      self.class::USAGE_RX
    end

    def expect_invite
      expect :styled, invite_rx
    end

    def invite_rx
      self.class::INVITE_RX
    end

  end

  # (for #posterity this node is attributed with being an early, if not the
  # first, spot that did something resembing the [#150] `expecting` facility.
  # this is a tombstone for that b.c it was really quite awful. wait, that's
  # not what it was.)
end
