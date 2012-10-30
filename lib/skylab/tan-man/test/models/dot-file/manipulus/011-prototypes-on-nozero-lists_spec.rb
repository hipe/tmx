require_relative '../test-support'

describe "#{Skylab::TanMan::Models::DotFile} Prototypes w nonzero lists" do
  extend ::Skylab::TanMan::Models::DotFile::TestSupport

  using_input '011-prototype-with/zero.dot' do
    it 'can add a node to zero nodes' do
      result.nodes.length.should eql(0)
      o = result.node! 'cyan'
      o.unparse.should eql("cyan [label=cyan]") # :node_stmt
      result.nodes.length.should eql(1)
      result.nodes.map { |n| n.node_id }.should eql([:cyan])
      result.unparse[-5..-1].should eql("n]\n}\n")
    end
  end

  using_input '011-prototype-with/one-that-comes-before.dot' do
    it 'can add a node to one node' do
      result.nodes.length.should eql(1)
      o = result.node! 'cyan'
      result.nodes.length.should eql(2)
      result.nodes.map { |n| n.node_id }.should eql([:blue, :cyan])
      o.unparse.should eql("cyan [label=cyan]")
      lines = result.unparse.split("\n")
      lines.pop.should eql('}')
      lines.pop.should eql('cyan [label=cyan]')
      lines.pop.should eql('blue [label=blue]')
    end
  end

  using_input '011-prototype-with/one-that-comes-after.dot' do
    it 'can add a node to one node' do
      result.nodes.length.should eql(1)
      o = result.node! 'cyan'
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

  using_input '011-prototype-with/three.dot' do
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
        result.node! 'zap'
        get [:gamma, :alpha, :yeti, :zap]
      end
      def add str
        result.node! str
      end
      def get arr
        result.nodes.map(&:node_id).should eql(arr)
      end
    end
  end
end
