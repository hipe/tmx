require_relative 'my-test-support'

module Skylab::Flex2Treetop::MyTestSupport
  describe Skylab::Flex2Treetop do
    extend CLI::ModuleMethods ; include CLI::InstanceMethods
    context "has a CLI that" do
      context "with no args" do
        argv
        an_explanation "of what it's expecting", /expecting.+flexfile/i
        an_invite
      end
      context "with one nonsensical option" do
        argv '-x'
        an_explanation "that the option is invalid", /invalid option.+x/
        an_invite
      end
      context "with the -h help flag" do
        argv '-h'
        it "displays the help screen" do
          err[0] = unstylize(err[0])
          err[0].should match(/usage: xyzzy .{24,} <flexfile>/i)
          listing = err[1..-1]
          listing.length.should be > 0
          _bad = listing.select { |s| s !~ /\A[[:space:]]+/ }
          _bad.length.should eql(0)
        end
      end
      context "with one giberrsh arg" do
        argv 'not-there.txt'
        an_explanation "that the file is not found",
          /file.+not found.+not-there\.txt/
        an_invite
      end
      context "reads flexfiles" do
        context "from a file named by ARG1" do
          argv fixture(:tokens)
          it "and writes a treetop grammar to stdout" do
            # io_adapter_spy.debug!
            out = self.out.reverse # look! (begin)
            out.length.should be_within(50).of(137)
            out.pop.should match(Flex2Treetop::AUTOGENERATED_RE)
            out.pop.should match(/from flex name definitions/i)
            out.pop.should match(/rule ident/)
            out.first.should eql('end') # look! (end)
            err.length.should be >= 1
            err.last.should match(/notice.+skipping/i)
          end
        end
      end
    end
  end
end
