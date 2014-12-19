require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Parse

  describe "[mh] Parse" do

    it "`fuzzy_metcher` generates pass filter procs with a specified precision" do
      p = Subject_[].fuzzy_matcher 3, 'foobie'

      p[ 'f' ].should eql nil
      p[ 'foo' ].should eql true
      p[ 'foob' ].should eql true
      p[ 'foobie-doobie' ].should eql nil
    end
    it "`hack_label` hacks an `as_human`-ish label from e.g an ivar name" do
      p = Subject_[].hack_label

      p[ :@foo_bar_x ].should eql "foo bar"
      p[ :some_method ].should eql "some method"
    end
  end
end
