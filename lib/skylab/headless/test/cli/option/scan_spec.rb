require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Option

  describe "[hl] CLI option scan" do

    it "normative" do

      op = Headless_::Library_::OptionParser.new
      op.on '-x', '--ex'
      op.on '-y', '--yes[=ok]'
      scn = Subject_[].scan op
      sw = scn.gets
      sw.short.last.should eql '-x'
      sw = scn.gets
      sw.long.first.should eql '--yes'
      sw = scn.gets
      sw.should be_nil
      scn.gets.should be_nil
    end
  end
end
