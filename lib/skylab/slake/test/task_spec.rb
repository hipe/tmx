require File.expand_path('../../task', __FILE__)
require File.expand_path('../support', __FILE__)

module Skylab::Slake
  describe Task do
    it "should build" do
      task = Task.new(FakeParent)
      task.parent_graph.should eq(FakeParent)
    end
  end
end
