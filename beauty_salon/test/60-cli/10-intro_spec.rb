require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe "[bs] CLI - intro" do

    TS_[ self ]
    use :CLI

    it "ping" do

      invoke 'ping'
      expect :e, "hello from beauty salon."
      expect_no_more_lines
      @exitstatus.should eql :hello_from_beauty_salon
    end

    it "help screen" do

      invoke '-h'

      _guy = flush_invocation_to_help_screen_tree

      sect = _guy.children[ 1 ]

      _rx = Home_.lib_.brazen::CLI_Support::Styling::SIMPLE_STYLE_RX
      s = sect.x.string.gsub _rx, EMPTY_S_
      s or fail

      4 <= sect.children.length or fail

    end
  end
end
