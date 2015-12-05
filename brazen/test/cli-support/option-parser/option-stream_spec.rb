require_relative '../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI - option parser - option stream" do

    it "normative" do

      op = Home_.lib_.stdlib_option_parser.new
      op.on '-x', '--ex'
      op.on '-y', '--yes[=ok]'
      scn = Home_::CLI_Support::Option_Parser::Option_stream[ op ]
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
