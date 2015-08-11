require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] proxy - inline - generated" do

    extend TS_

    it "produce a proxy \"inline\" from a hash-like whose values are procs" do

      pxy = Home_::Proxy::Inline.new(
        :foo, -> x { "bar: #{ x }" },
        :biz, -> { :baz } )

      pxy.foo( :wee ).should eql "bar: wee"

      pxy.biz.should eql :baz
    end
  end
end
