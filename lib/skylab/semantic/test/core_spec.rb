require_relative 'test-support'

module Skylab::Semantic::TestSupport

  # le Quickie.

  describe "#{ Semantic::Digraph }" do
    it "here have an empty one" do
      digraph = Semantic::Digraph.new
      digraph.nodes_count.should eql( 0 )
    end

    it "here have one with one node" do
      digraph = Semantic::Digraph.new :solo
      digraph.nodes_count.should eql( 1 )
      node = digraph[:solo]
      node.name.should eql( :solo )
    end

    it "here have the minimal graph" do
      digraph = Semantic::Digraph.new child: :parent
      digraph.nodes_count.should eql( 2 )
      digraph[:child].name.should eql( :child )
      digraph[:parent].name.should eql( :parent )
      digraph[:child].is_names.should eql( [:parent] )
    end

    it "did you know that you can use `has?`", f:true do
      d = Semantic::Digraph.new :mineral, dog: :animal
      (d.has?( :mineral ) && d.has?( :dog ) && d.has?( :animal )).should(
        eql( true ) )
      d.has?( :aardvark ).should eql( false )
    end

    context 'all ancestor names' do
      it 'works recursively, depth-first' do
        digraph = Semantic::Digraph.new animal: :thing, penguin: :animal,
          mineral: :thing, tux: [ :penguin, :icon ], my_tux_sticker: :tux

        digraph[:my_tux_sticker].all_ancestor_names.should eql(
          [ :my_tux_sticker, :tux, :penguin, :animal, :thing, :icon ]
        )
      end
    end
  end
end
