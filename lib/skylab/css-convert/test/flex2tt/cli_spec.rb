require_relative 'my-test-support'

module Skylab::FlexToTreetop::MyTestSupport
  describe Skylab::FlexToTreetop do
    extend ModuleMethods ; include InstanceMethods
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
          err[0].should match(/usage: xyzzy \[options\] <flexfile>/i)
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
          argv ::Skylab::ROOT.join(
            'lib/skylab/css-convert/css-parser/tokens.flex').to_s
          it "and writes a treetop grammar to stdout" do
            # io_adapter_spy.debug!
            out.length.should be_within(50).of(137)
            out.first.should match(/from flex name definitions/i)
            out[1].should match(/rule ident/)
            out.last.should eql('end')
            err.length.should be >= 1
            err.last.should match(/notice.+skipping/i)
          end
        end
      end
    end
  end
end
