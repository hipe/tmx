require_relative 'my-test-support'

module Skylab::FlexToTreetop::MyTestSupport
  describe Skylab::FlexToTreetop do
    extend ModuleMethods ; include InstanceMethods
    context "has an API that" do
      context "when you request a nonexistent action" do
        it "raises a runtime error" do
          result = api_client.invoke(:wiggle)
          -> { result.__result__ }.should raise_error(
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
    end
  end
end
