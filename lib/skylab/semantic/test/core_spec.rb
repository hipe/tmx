require_relative 'test-support'

describe "#{::Skylab::Semantic::Digraph}" do
  self::Semantic = ::Skylab::Semantic

  it "here have an empty one" do
    digraph = Semantic::Digraph.new
    digraph.nodes_count.should eql(0)
  end

  it "here have one with one node" do
    digraph = Semantic::Digraph.new(:solo)
    digraph.nodes_count.should eql(1)
    node = digraph[:solo]
    node.name.should eql(:solo)
  end

  it "here have the minimal graph" do
    digraph = Semantic::Digraph.new(child: :parent)
    digraph.nodes_count.should eql(2)
    digraph[:child].name.should eql(:child)
    digraph[:parent].name.should eql(:parent)
    digraph[:child].is_names.should eql([:parent])
  end
end
