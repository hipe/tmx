require_relative '../test-support'

module Skylab::Snag::TestSupport::CLI::Actions

  describe "[sg] CLI actions node close" do

    extend TS_

    with_invocation 'node', 'close'

    with_manifest <<-O.unindent
        [#003] #open biff bazz
          this second line will get concatted
        [#002]       #done this one is finished
        [#001]      this one has no markings and 6 spaces of ws
      O

    it "closing one with a funny looking name - whines gracefully" do
      setup_tmpdir_read_only
      invoke 'abc'
      expect :info, /invalid identifier name/
    end

    it "closing one that doesn't exist - whines gracefully" do
      setup_tmpdir_read_only
      invoke '867'
      expect :info,
        /failed to close node.*there is no node with the identifier "867"/i
    end

    it "closing one that is already closed - whines gracefully" do
      setup_tmpdir_read_only
      invoke '002'
      expect :info, /\[#002\] is not tagged with "#open"/ # [#it-002] agg.
      expect :info, /\[#002\] is already tagged with #done/
    end

    it "closing one that has no taggings at all - works, reindents" do
      invoke '001'
      expect :info, /\[#001\] is not tagged with .*#open/
      expect :info, /prepended #done/
      lines = @pn.read.split "\n"
      lines[3].should match( /^\[#001\] {7}#done/ )
    end

    it "closing one that is open and has multiline - works, munges lines" do
      invoke '003'
      expect :info, /removed #open/
      expect :info, /prepended #done/
      lines = @pn.read.split "\n"
      lines.first.should match( /^\[#003\] *#done biff bazz.*get concatted$/ )
      lines[1].should match( /^\[#002\]/ )
    end
  end
end
