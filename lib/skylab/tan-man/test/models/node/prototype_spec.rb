require_relative 'test-support'

module Skylab::TanMan::TestSupport::Models::Node

  # Quickie?

  describe "#{ Skylab::TanMan::Models::Node } prototypes" do
    extend ::Skylab::TanMan::TestSupport::Models::Node


    using_input 'simple-prototype-and-graph-with/zero.dot' do
      it 'can add a node to zero nodes' do
        result.nodes.length.should eql(0)
        o = controller.node! 'cyan'
        o.unparse.should eql("cyan [label=cyan]") # :node_stmt
        result.nodes.length.should eql(1)
        result.nodes.map { |n| n.node_id }.should eql([:cyan])
        result.unparse[-5..-1].should eql("n]\n}\n")
      end

      context 'having quotes in labels' do
        it 'that are unescaped unparses AND stringifies correctly' do
          str = %<it's a quote: ">
          o = controller.node! str
          o.unparse.should be_include('[label="it\'s a quote: \""]')
          o.label.should eql(str)
        end
      end
    end


    using_input 'simple-prototype-and-graph-with/one-that-comes-before.dot' do
      it 'can add a node to one node' do
        result.nodes.length.should eql(1)
        o = controller.node! 'cyan'
        result.nodes.length.should eql(2)
        result.nodes.map { |n| n.node_id }.should eql([:blue, :cyan])
        o.unparse.should eql("cyan [label=cyan]")
        lines = result.unparse.split("\n")
        lines.pop.should eql('}')
        lines.pop.should eql('cyan [label=cyan]')
        lines.pop.should eql('blue [label=blue]')
      end
    end

    using_input 'simple-prototype-and-graph-with/one-that-comes-after.dot' do
      it 'can add a node to one node' do
        result.nodes.length.should eql(1)
        o = controller.node! 'cyan'
        result.nodes.length.should eql(2)
        result.nodes.map { |n| n.node_id }.should eql([:cyan, :red])
        o.unparse.should eql("cyan [label=cyan]")
        lines = result.unparse.split("\n")
        lines.pop.should eql('}')
        lines.pop.should eql('') # we made an extra one on purpose
        lines.pop.should eql('red [label=red]')
        lines.pop.should eql('cyan [label=cyan]')
        lines.pop.should eql('')
        lines.pop.should eql('*/')
      end
    end

    using_input 'simple-prototype-and-graph-with/three.dot' do
      context 'it adds nodes "alphabetically" but does not rearrange existing' do
        it 'when first one comes after new one, new one goes first' do
          add 'beta'
          get [:beta, :gamma, :alpha, :yeti]
        end
        it '(inside)' do
          add 'ham'
          get [:gamma, :alpha, :ham, :yeti]
        end
        it '(last)' do
          controller.node! 'zap'
          get [:gamma, :alpha, :yeti, :zap]
        end
        def add str
          controller.node! str
        end
        def get arr
          result.nodes.map(&:node_id).should eql(arr)
        end
      end

      it 'will not redundantly add a new node if one with same label exists' do
        result.nodes.length.should eql(3)
        (item = result.node_with_id :yeti).should_not be_nil
        ohai = controller.node!('yeti')
        ohai.object_id.should eql(item.object_id)
        result.nodes.length.should eql(3)
      end
    end
  end
end
