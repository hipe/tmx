require_relative 'test-support'

module Skylab::Callback::TestSupport::Box

  describe "[cb] box struct" do

    extend TS_

    it "requires at least 1 entry" do

      Subject_[].new.to_struct.should eql false

    end

    memoize_subject do

      bx = Subject_[].new
      bx.add :foo, :Foo
      bx.add :bar, :Bar
      bx.to_struct

    end

    it "looks like struct" do
      subject.members.should eql [ :foo, :bar ]
    end

    it "does certain box-like things" do
      subject.at( :bar, :foo ).should eql [ :Bar, :Foo]
    end
  end
end
