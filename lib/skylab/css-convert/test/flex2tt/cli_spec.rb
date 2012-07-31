require_relative 'my-test-support'

module Skylab::FlexToTreetop::MyTestSupport
  describe Skylab::FlexToTreetop do
    extend ModuleMethods ; include InstanceMethods
    context "has a CLI that" do
      context "with no args" do
        argv
        an_explanation "of what it's expecting", /expecting.+flexfile/i
        more_help
      end
      context "with one nonsensical option" do
        argv '-x'
        an_explanation "that the option is invalid", /invalid option.+x/
        more_help
     end
      context "with one giberrsh arg" do
        argv 'not-there.txt'
        an_explanation "that the file is not found",
          /file.+not found.+not-there\.txt/
        more_help
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
