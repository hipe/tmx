require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] stack - intro" do

    TS_[ self ]
    use :expect_event

    it "loads" do
      _subject
    end

    it "the empty stack will never find anything" do
      stack = _subject.new
      stack.any_proprietor_of( :anything ).should be_nil
    end

    it "the stack with one frame produces the values it has" do
      stack = _subject.new
      stack.push_frame_with :foo, :Foo, :bar, :Bar
      stack.dereference( :foo ) == :Foo || fail
      stack.dereference( :bar ) == :Bar || fail
    end

    it "the first frame determines what names the subsequent frames may have" do

      stack = _subject.new( & handle_event_selectively_ )
      stack.push_frame_with :a, :X, :b, :Y
      x = stack.push_frame_with :derp, :Z, :b, :B, :nerp, :Q
      x.should eql false

      expect_not_OK_event :unrecognized_argument do |ev|
        ev.unrecognized_tokens == [ :derp, :nerp ] || fail
      end

      expect_no_more_events
    end

    it "strange name frame with no event receiver will raise an exeption" do
      stack = _subject.new
      stack.push_frame_with :a, :X, :b, :Y
      begin
        stack.push_frame_with :derp, :Z, :b, :B, :nerp, :Q
      rescue Home_::ArgumentError => e
      end
      e.message.should match %r(\Aunrecognized attributes 'derp' and 'nerp')
    end

    it "topmost frame wins" do
      stack = _subject.new
      stack.push_frame_with :a, :A1, :b, :B1, :c, :C1
      stack.push_frame_with :b, :B2, :c, :c2
      stack.push_frame_with :c, :C3

      stack.dereference( :a ) == :A1 || fail
      stack.dereference( :b ) == :B2 || fail
      stack.dereference( :c ) == :C3 || fail
    end

    it "strange value when event receiver produces the same event as earlier" do
      stack = _subject.new( & handle_event_selectively_ )
      stack.push_frame_with :a, :A1, :b, :B1
      stack.push_frame_with :b, :B2
      x = stack.dereference :c

      expect_not_OK_event :unrecognized_argument do |ev|
        ev.unrecognized_token == :c || fail
      end

      expect_no_more_events
      x.should eql false
    end

    def _subject
      Home_::Stack
    end
  end
end
