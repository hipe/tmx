require_relative '../test-support'

module Skylab::Brazen::TestSupport::CLI

  describe "[br] CLI - option parser - option stream" do

    it "normative" do

      op = Home_::CLI::Option_parser___[].new
      op.on '-x', '--ex'
      op.on '-y', '--yes[=ok]'
      scn = Home_::CLI::Option_Parser::Option_stream[ op ]
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
