require_relative 'test-support.rb'

describe "#{::Skylab::Headless::Parameter} {reader|writer|accessor}: true" do
  extend ::Skylab::Headless::Parameter::TestSupport
  context "with reader:true" do
    defn do
      param :foo_readonly, reader: true
    end
    frame do
      it "you get foo but not foo=" do
        object.foo_readonly.should be_nil
        object.send(:[]=, :foo_readonly, :biz)
        object.foo_readonly.should eql(:biz)
        -> { object.foo = :baz }.should raise_error(::NoMethodError)
      end
    end
  end
  context "with writer:true" do
    defn do
      param :foo_writeonly, writer: true
    end
    frame do
      it "you get foo= but not foo" do
        object.send(:[], :foo_writeonly).should be_nil
        object.foo_writeonly = :blue
        object.send(:[], :foo_writeonly).should eql(:blue)
        -> { object.foo_writeonly }.should raise_error(::NoMethodError)
      end
    end
  end
  context "with accessor:true" do
    defn do
      param :foo_accessor, accessor: true
    end
    frame do
      it "you get both" do
        object.foo_accessor.should be_nil
        object.foo_accessor = :blue
        object.foo_accessor.should eql(:blue)
      end
    end
  end
end
