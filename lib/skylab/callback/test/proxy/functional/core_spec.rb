require_relative 'test-support'

module Skylab::Callback::TestSupport::Proxy::Functional

  describe "[ca] Proxy::Functional__" do

    context "make a 'fuctional' proxy class with a list of member names" do

      before :all do
        My_Proxy = Subject_[].functional :foo, :baz
      end
      it "build a proxy instance by passing it procs to implement the fields" do
        pxy = My_Proxy.new :foo, -> x { "bar: #{ x }" },
          :baz, -> { :BAZ }

        pxy.foo( :wee ).should eql "bar: wee"
        pxy.baz.should eql :BAZ
      end
    end
  end
end
