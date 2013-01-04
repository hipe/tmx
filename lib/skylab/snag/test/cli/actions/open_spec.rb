require_relative 'test-support'


module Skylab::Snag::TestSupport::CLI::Actions

  # Quickie compatible! - just load this file with `ruby -w`

  describe "#{ Snag::CLI } Actions - Open" do

    extend Actions_TestSupport

    shared_setup = -> ctx do                   # differently just for fun
      ctx.tmpdir_clear.write 'doc/issues.md', <<-O.unindent
        [#004.2] #open this is #feature-creep but meh
        [#004] #open here's an open guy
                        with two lines
        [#003]        not open because no such tag
        [#002]       look for job #openings somewhere else
        [#leg-001]   this is an old ticket that is still #open
                       it has a prefix which will hopefully be ignored
      O
      shared_setup = -> _ { }
    end

    context "with no arguments show a report of open tickets!" do
      it "`open` (with no options) - shows a subset of lines from the file" do
        shared_setup[ self ]
        invoke_from_tmpdir 'o'
        a = output.lines
        :info == a.first.name and a.shift
        a.map(& :name).should eql(
          [:pay, :pay, :pay, :pay, :pay, :info] )
        exp = <<-O.unindent
          [#004.2] #open this is #feature-creep but meh
          [#004] #open here's an open guy
                          with two lines
          [#leg-001]   this is an old ticket that is still #open
                         it has a prefix which will hopefully be ignored
        O
        act = a[0..-2].map(&:string).join
        act.should eql( exp )
      end

      it "`open -v` - show it verbosely (the yaml report)" do
        shared_setup[ self ]

      end
    end

    it "with one argument - opens a ticket"
  end
end
