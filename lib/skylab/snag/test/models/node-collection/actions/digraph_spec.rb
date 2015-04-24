require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - n.c - actions - digraph", wip: true do

    extend TS_

    context "minimal expemplary" do

      it "ok" do
        @message_s = 'foo boff biz bazz'
        subject
        @line_a.should eql [ "foo", "boff biz", "bazz" ]
        expect_succeeded
      end
    end

    context "but alas, when exceeds line limit" do

      let :max_lines do 2 end

      it "x" do
        @message_s = 'foo boff biz bazz'
        subject
        expect :error_event, :message_line_limit_exceeded do |ev|
          s = render_terminal_event ev
          s.should match %r(\b2 line limit\b)
          s.should be_include '(near (ick bazz))'
        end
      end
    end

    def subject
      @result = Snag_::Models::Node::Controller__::Delineate_message__[
        extra_lines_header, line_width, listener_spy,
        max_lines, message_s,
        do_prepend_open_tag, do_prepend_open_tag_ws, y_p ]
    end

    def extra_line_a
      @extra_line_a ||= []
    end

    attr_reader :extra_lines_header

    def first_line_p
      @first_line_a ||+ []
      @first_line_p ||= -> s do
        @first_line_a.push s ; nil
      end
    end

    def line_width
      10
    end

    def max_lines
      3
    end

    attr_reader :message_s

    attr_reader :do_prepend_open_tag

    attr_reader :do_prepend_open_tag_ws

    def y_p
      @line_a ||= []
      @y_p ||= -> s { @line_a.push s }
    end
  end
end
