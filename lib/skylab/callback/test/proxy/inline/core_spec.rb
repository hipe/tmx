require_relative 'test-support'

module Skylab::Callback::TestSupport::Proxy::Inline

  ::Skylab::Callback::TestSupport::Proxy[ self ]

  include Constants

  extend TestSupport_::Quickie

  Callback_ = Callback_

  Subject_ = -> * x_a, & p do
    if x_a.length.nonzero? || p
      Callback_::Proxy::Inline__[ * x_a, & p ]
    else
      Callback_::Proxy::Inline__
    end
  end

  describe "[ca] Proxy::Inline__" do

    it "produce a proxy \"inline\" from a hash-like whose values are procs" do
      pxy = Subject_.call(
        :foo, -> x { "bar: #{ x }" },
        :biz, -> { :baz } )

      pxy.foo( :wee ).should eql "bar: wee"

      pxy.biz.should eql :baz
    end
  end
end
