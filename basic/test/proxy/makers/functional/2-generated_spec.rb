require_relative '../../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] proxy - makers - functional - 2. generated" do

    extend TS_

    context "make a 'fuctional' proxy class with a list of member names" do

      it "build a proxy instance by passing it procs to implement the fields" do

        _My_Proxy = Home_::Proxy::Makers::Functional.new :foo, :baz

        pxy = _My_Proxy.new :foo, -> x { "bar: #{ x }" },
          :baz, -> { :BAZ }

        pxy.foo( :wee ).should eql "bar: wee"
        pxy.baz.should eql :BAZ
      end
    end
  end
end
