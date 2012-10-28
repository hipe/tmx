require_relative '../test-support'

describe "#{Skylab::TanMan::Models::DotFile} Adding Nodes" do
  extend ::Skylab::TanMan::Models::DotFile::TestSupport

  using_input '009.1-add-node-simple-prototype.dot' do
    it 'can add a node to zero nodes' do
      result.nodes.should eql([])
      o = result.node! 'feep'
      a = result.nodes
      a.length.should eql(1)
      result.stmt_list.unparse.should eql("feep [label=feep]\n")
    end
    it 'can add a node to one node'
    it 'can add a node to two nodes, alphabeticaly'
    it 'note it does not re-arrange the existing nodes'
  end
end
