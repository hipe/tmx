require_relative '../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] models - the hear front" do

    TS_[ self ]

    it "unrecognized input" do
      call_API :hear, :word, [ 'zing', 'zang' ]
      ev = expect_not_OK_event :unrecognized_utterance
      s_a = black_and_white_lines ev
      ( 7 .. 9 ).should be_include s_a.length
    end
  end
end
