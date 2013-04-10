require_relative 'test-support'

module ::Skylab  # [#ts-010]

  TestSupport::Quickie.enable_kernel_describe

# ..

describe "#{ Slake::Graph }" do

  let( :graph ) { Slake::Graph.new }
  describe "when built empty" do
    it "does nothing interesting" do
      graph.nodes.empty?.should eql(true)
      graph.parent?.should eql(false)
      graph.should be_respond_to(:parent=)
    end
    it "will raise an exception when invoke() is called since no target task is defined" do
      lambda{ graph.invoke }.should raise_error(/graph does not have a "target" attribute/i)
    end
  end
  describe "when adding tasks to an empty graph" do
    describe "using add_task()" do
      it "if you add a task with an empty name it will raise an exception" do
        task = Slake::Task.new name: nil  # intentionally force it to be blank
        lambda{ graph.add_task task }.should raise_error(/cannot have an empty name/)
      end
      it "if it has a name it will let you add and then retrieve a task (but remember it stringifies names)" do
        t = Slake::Task.new name: :foo
        graph.add_task t
        t.object_id.should eql(graph['foo'].object_id)
      end
    end
    describe "using []=" do
      it "it will use 'indifferent' access (stringify all keys) (per rake)" do
        t = Slake::Task.new
        graph[:foo] = t
        lambda{ graph['foo'] = t }.should raise_error(/won't clobber/) # @todo this needs its own test
        graph[:foo].object_id.should eql(t.object_id)
        graph['foo'].object_id.should eql(t.object_id)
      end
      it "if the task has any empty name it will get changed to the key" do
        t = Slake::Task.new
        t.name.should eql('')
        graph['foo'] = t
        t.name.should eql('foo')
      end
      describe "with a task that already has a name" do
        let(:task) { Slake::Task.new name: :foo }
        it "will let you add it to the graph using the same name" do
          id = task.object_id
          graph['foo'] = task
          graph['foo'].object_id.should eql(id)
        end
        it "will raise an exception if you use the wrong name" do
          lambda{ graph['bar'] = task }.should raise_error(/must use the same name/i)
        end
      end
    end
  end


  describe "with a graph with one task, set as target" do
    let(:graph) do
      Slake::Graph.new(
        :name => 'test1',
        :target => 'do this whootily',
          'do this whootily' => Slake::Task.new(
            action: -> task, args do
              args[:context][:touched] = true
            end
          )
      )
    end
    it "it can be invoked with a context argument passed to it" do
      context = { :touched => false }
      graph.invoke context
      context[:touched].should eql(true)
    end
  end

  describe "with a graph with two tasks with a unidirectional dependency" do
    let(:graph) do
      Slake::Graph.new(
        :target => :foo,
        :foo => Slake::Task.new(
          :prerequisites => [:bar],
          :action => ->(t, a) { a[:context][:list].push :foo }
        ),
        :bar => Slake::Task.new(
          :action => ->(t, a) { a[:context][:list].push :bar }
        )
      )
    end
    it "it will call the dependencies in the expected manner" do
      context = { :list => [] }
      graph = self.graph
      graph.invoke context
      context[:list].should eql [:bar, :foo]
    end
  end
end
# ..
end
