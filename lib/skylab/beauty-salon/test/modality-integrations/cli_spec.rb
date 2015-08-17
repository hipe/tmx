require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe "[bs] mode-integrations - CLI" do

    extend TS_
    use :modality_integrations_CLI_support

    it "ping" do

      invoke 'ping'
      expect :e, "hello from beauty salon."
      expect_no_more_lines
      @exitstatus.should eql :hello_from_beauty_salon
    end

    it "help screen" do

      invoke '-h'

      _guy = flush_help_screen_to_tree

      sect = _guy.children[ 1 ]

      _rx = Home_.lib_.brazen::CLI::Styling::SIMPLE_STYLE_RX
      s = sect.x.line.gsub _rx, EMPTY_S_
      s or fail

      4 <= sect.children.length or fail

    end
  end
end
