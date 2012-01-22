require File.expand_path('../../task', __FILE__)

describe ::Skylab::Slake::Task do

  include ::Skylab::Slake

  it "descends from Rake::Task (fyi)" do
    Task.new.should be_kind_of(::Rake::Task)
  end

  it "defines settable/gettable attributes in the class" do
    klass = Class.new(Task).class_eval do
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
    it "can define its slake() method with a lambda (how it is executed is undefined)" do
      touched = false
      t = Task.new(:slake => ->(){ touched = true })
      t.invoke
      touched.should eql(true)
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

  describe "when it comes to parents, it" do
    FakeParent = Class.new.class_eval do
      self
    end.new

    let(:task) { ::Skylab::Slake::Task.new }
    it "has no parent by default (of course!)" do
      task.parent?.should eql(false)
      task.parent.should eql(nil)
    end
    it "can be given a parent" do
      task.parent = FakeParent
      task.parent?.should eql(true)
      task.parent.should eql(FakeParent)
    end
  end

  describe "with regards to its name, rake parent stringifies all names so" do
    it "a minimal Task object has \"\" for a name" do
      Task.new.name.should eql('')
    end
    it "if you set it explicitly to nil it will still be \"\"" do
      Task.new(:name => nil).name.should eql('')
    end
    it "and will call to_s on whatever name you give it (like false)" do
      Task.new(:name => false).name.should eql('false')
    end
  end
end

