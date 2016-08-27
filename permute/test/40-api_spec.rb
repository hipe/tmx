require_relative 'test-support'

module Skylab::Permute::TestSupport

  describe "[pe] models" do

    extend TS_
    use :expect_event

    it "pings." do

      call_API :ping

      :hello_from_permute == @result or fail

      expect_neutral_event :ping, 'hello from (app_name).'
    end

    it "ok." do

      call_API(
        :generate,
        :pair, :a, :b,
        :pair, :a, :c,
        :pair, :d, :e )

      expect_no_events

      st = @result
      sct = st.gets
      sct.members.should eql [ :a, :d ]
      sct.to_a.should eql [ :b, :e ]
      sct = st.gets
      sct.to_a.should eql [ :c, :e ]
      st.gets.should be_nil
    end
  end
end
