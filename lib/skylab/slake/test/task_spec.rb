require File.expand_path('../../task', __FILE__)
require File.expand_path('../support', __FILE__)

module Skylab::Slake
  describe Task do
    it "should build and do parent stuff" do
      task = Task.new
      task.has_parent?.should eq(nil)
      task.respond_to?(:parent_graph).should eq(false)
      task.meet_parent_graph FakeParent
      task.has_parent?.should eq(true)
      task.parent_graph.should eq(FakeParent)
      task.children.should eq(nil)
    end
  end
end
