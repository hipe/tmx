require_relative '../test-support'

describe "#{Skylab::TanMan::Models::DotFile} (010) associate nodes" do
  extend ::Skylab::TanMan::Models::DotFile::TestSupport

  using_input '009-add-node-simple-prototype/zero.dot' do
    it 'associates nodes when neither exists, creating them' do
      o = result.associate! 'one', 'two'
      o.unparse.should eql('one -> two')
      lines = result.unparse.split("\n")
      lines[-3..-1].should eql(["two [label=two]", "one -> two", "}"])
    end
  end

  using_input '010-edges/2-nodes-0-edges.dot' do
    it 'associates when first exists, second does not' do
      o = result.associate! 'alpha', 'peanut gallery'
      lines = result.unparse.split("\n")
      lines[-3..-1].should eql(
        ['peanut [label="peanut gallery"]', 'alpha -> peanut', '}' ])
    end
  end

  using_input '010-edges/2-nodes-1-edge.dot' do
    it 'does not associate again redundantly' do
      result._edge_stmts.to_a.length.should eql(1)
      result.associate! 'alpha', 'gamma'
      result._edge_stmts.to_a.length.should eql(1)
    end
  end

  using_input '010-edges/0-nodes-3-edges.dot' do
    it 'adds edges alphabetic-ish-ly, contiguous-esque' do
      result._edge_stmts.to_a.length.should eql(3)
      result._node_stmts.to_a.length.should eql(0)
      result.associate! 'feasly', 'teasly'
      result._edge_stmts.to_a.length.should eql(4)
      result._node_stmts.to_a.length.should eql(2) # it created one that it ..
      lines = result.unparse.split("\n")
      lines[-5..-1].should eql(['beasly -> teasly', 'feasly -> teasly',
        'gargoyle -> flargoyle', 'ainsly -> fainsly', '}'])
    end
  end

  context "with complex arcs" do
    it 'lets you specify a label for the association, using a prototype'
  end
end
