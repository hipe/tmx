require_relative 'test-support'

module Skylab::Task::TestSupport  # [#ts-010]

  TestSupport_::Quickie.enable_kernel_describe

# ..
describe "[ta] task" do

  it "descends from Rake::Task (fyi)" do
    Home_::LegacyTask.new.should be_kind_of ::Rake::Task
  end

  it "defines settable/gettable attributes in the class" do
    klass = ::Class.new( Home_::LegacyTask ).class_eval do
      attribute :some_val
      self
    end
    t = klass.new
    t.some_val.should eql(nil)
    t.some_val = 'foo'
    t.some_val.should eql('foo')
  end

  describe "has different ways of describing its actions:" do
    describe "When it overrides the execute() method of rake parent" do
      class SomeTask < Home_::LegacyTask
        def execute args
          @touched = true
        end
        attr_accessor :touched
      end
      it "it will run that badboy when it is invoked" do
        t = SomeTask.new
        t.touched.should eql(nil)
        t.invoke
        t.touched.should eql(true)
      end
    end
    describe "When you call enhance() (per rake)" do
      it "it works" do
        touched = false
        t = Home_::LegacyTask.new.enhance{ touched = true }
        t.invoke
        touched.should eql(true)
      end
    end
    describe "When you set the action attribute to a lambda" do
      it "it works (provided you have the right arity)" do
        touched = false
        Home_::LegacyTask.new(:action => ->(t) { touched = true }).invoke
        touched.should eql(true)
      end
    end
  end

  describe "with regards to passing arguments to the task" do
    let(:str) { "" }
    let(:t) do
      Home_::LegacyTask.new(:action => ->(t, args) { str.replace "args: #{args.inspect}" })
    end
    it "if you pass zero arguments to invoke(), it will have an empty args hash" do
      t.invoke()
      str.should eql('args: {}')
    end
    it "if you pass it one argument, it will use the default value of its arg_names attribute, [:context]" do
      t.invoke('a')
      str.should eql('args: {:context=>"a"}')
    end
    it "if you pass more than one argument to invoke(), by default they are ignored" do
      t.invoke('a', 'b')
      str.should eql('args: {:context=>"a"}')
    end
  end

  describe "can define attributes as being interpolated" do
    it "and can then make references to other attributes" do
      klass = ::Class.new( Home_::LegacyTask ).class_eval do
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
    FakeParent = ::Class.new.class_eval do
      self
    end.new

    let(:task) { Home_::LegacyTask.new }
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

  describe "with regards to its name, the rake parent stringifies all names so" do
    it "a minimal Task object has \"\" for a name" do
      Home_::LegacyTask.new.name.should eql('')
    end
    it "if you set it explicitly to nil it will still be \"\"" do
      Home_::LegacyTask.new(:name => nil).name.should eql('')
    end
    it "and will call to_s on whatever name you give it (like false)" do
      Home_::LegacyTask.new(:name => false).name.should eql('false')
    end
  end
end
# ..
end
