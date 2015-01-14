require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Parse

  describe "[mh] Parse" do

    it "hack a human-readable name from an internal name" do
      p = Subject_[].hack_moniker_

      p[ :@foo_bar_x ].should eql "foo bar"
      p[ :some_method ].should eql "some method"
    end
  end
end
