require_relative 'test-support'

describe "#{Skylab::TanMan::Models::DotFile} (manipulus 009) Adding Nodes" do
  extend ::Skylab::TanMan::Models::DotFile::Manipulus::TestSupport

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

  using_input '009.2-more-complex-prototype/first.dot' do
    it "has a restricted characterset for what it will allow in labels" do
      ->{ result.node! "\t\t\n\x7F" }.should raise_error(
        /the following characters are not yet supported: /)
    end
    it "will escape certain characters in labels" do
      o = result.node! 'joe\'s "mother" & i <wat>'
      o.unparse.should be_include(
        'joe&apos;s &quot;mother&quot; &amp; i &lt;wat&gt;')
      # ::File.open('TMP-VISUAL-TEST.dot', 'w+') { |fh| fh.write result.unparse }
    end
  end
end
