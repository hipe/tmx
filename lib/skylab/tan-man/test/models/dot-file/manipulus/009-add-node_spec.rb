require_relative '../test-support'

describe "#{Skylab::TanMan::Models::DotFile} Adding Nodes" do
  extend ::Skylab::TanMan::Models::DotFile::TestSupport

  using_input '009-add-node-simple-prototype/zero.dot' do
    it 'adds a node to zero nodes' do
      result.nodes.should eql([])
      o = result.node! 'feep'
      a = result.nodes
      a.length.should eql(1)
      result.stmt_list.unparse.should eql("feep [label=feep]\n")
    end

    it "creates unique but natural node_ids" do
      result.node! 'milk the cow'
      result.node! 'milk the cat'
      result.node! 'MiLk the catfish'
      result.nodes.map(&:node_id).should eql([:MiLk, :milk_2, :milk])
      a = result.nodes.map(&:label)
      a.shift.should eql('MiLk the catfish')
      a.shift.should eql('milk the cat')
      a.shift.should eql('milk the cow')
    end
  end
end
