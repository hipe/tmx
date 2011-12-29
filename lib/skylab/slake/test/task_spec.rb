require File.expand_path('../../task', __FILE__)

describe ::Skylab::Slake::Task do

  it "descends from Rake::Task (fyi)" do
    ::Skylab::Slake::Task.new.should be_kind_of(::Rake::Task)
  end

  it "defines settable/gettable attributes in the class" do
    klass = Class.new(::Skylab::Slake::Task).class_eval do
      attribute :some_val
      self
    end
    t = klass.new
    t.some_val.should eql(nil)
    t.some_val = 'foo'
    t.some_val.should eql('foo')
  end

  describe "when it defines a method called slake()" do
    class SomeTask < ::Skylab::Slake::Task
      def slake
        @touched = true
      end
      attr_accessor :touched
    end
    it "will run that badboy when it is invoked" do
      t = SomeTask.new
      t.touched.should eql(nil)
      t.invoke
      t.touched.should eql(true)
    end
  end

  describe "can define attributes as being interpolated" do
    it "and can then make references to other attributes" do
      klass = Class.new(::Skylab::Slake::Task).class_eval do
        attribute :foo, :interpolated => true
        attribute :bar
        self
      end
      t = klass.new(
        :foo => 'ABC{bar}GHI',
        :bar => 'DEF'
      )
      t.foo.should eql('ABCDEFGHI')
    end
  end

end

