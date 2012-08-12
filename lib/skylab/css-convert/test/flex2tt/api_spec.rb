require_relative 'my-test-support'

module Skylab::FlexToTreetop::MyTestSupport
  describe Skylab::FlexToTreetop do
    extend API::ModuleMethods ; include API::InstanceMethods
    context "has an API that" do
      context "when you request a nonexistent action" do
        it "raises a runtime error" do
          promise = api_client.invoke(:wiggle)
          -> { promise.__result__ }.should raise_error(
            FlexToTreetop::API::RuntimeError, /cannot wiggle/i)
        end
      end
      context "when you request the 'version' action" do
        it "returns the version string" do
          promise = FlexToTreetop::API.invoke(:version)
          promise.should be_kind_of(::String)
          promise.should match(/\A[ 0-9a-z]+ \d+(?:\.\d+)*\z/i)
        end
      end
      context "when you request the 'translate' action" do
        context "with good parameters" do
          before { tmpdir.prepare }
          let(:outfile) { tmpdir.join('out.rb') }
          it "it makes that badboy!", f:true do
            api_client.invoke(:translate,
              flexfile: fixture(:mini), outfile: outfile
            ).should eql(:translated)
            info.reverse!.pop.should match(
              /creating.+out\.rb with.+mini\.flex/)
            info.pop.should match(/can't deduce a.+rule/i)
          end
        end
      end
    end
    let(:info) { info_stream_lines }
  end
end
