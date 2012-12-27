require_relative 'test-support'

describe "#{Skylab::TanMan::Models::DotFile} (manipulus 010) associate nodes" do
  extend ::Skylab::TanMan::TestSupport::Models::DotFile::Manipulus

  using_input '009-add-node-simple-prototype/zero.dot' do
    it 'associates nodes when neither exists, creating them' do
      o = result.associate! 'one', 'two'
      o.unparse.should eql('one -> two')
      lines[-3..-1].should eql(["two [label=two]", "one -> two", "}"])
    end
  end

  using_input '010-edges/2-nodes-0-edges.dot' do
    it 'associates when first exists, second does not' do
      o = result.associate! 'alpha', 'peanut gallery'
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
      lines[-5..-1].should eql(['beasly -> teasly', 'feasly -> teasly',
        'gargoyle -> flargoyle', 'ainsly -> fainsly', '}'])
    end
  end

  using_input '010-edges/point-5-1-prototype.dot' do
    it 'uses any edge prototype called "edge_stmt"' do
      result.associate! 'foo', "bar's mother"
      lines[-2].should eql(%(foo -> bar [ penwidth = 5 fontsize = 28 #{
        }fontcolor = "black" label = "e" ]))
    end
  end

  using_input '010-edges/point-5-2-named-prototypes.dot' do
    it 'fails if you pick a weird name' do # 0633 0708
      ->{ result.associate!('a', 'b', prototype: :clancy) }.should(
        raise_error(/no such prototype :clancy/) )
    end
    it 'lets you choose which of several edge prototypes' do # 0708 0715
      result.associate!('c', 'd', prototype: :fancy)
      result.associate!('b', 'a', prototype: :boring)
      lines[-7..-2].should eql(
        ["a [label=a]", "b [label=b]", "c [label=c]", "d [label=d]",
        "b -> a [this=is not=fancy]", "c -> d [this=style is=fancy]"])
    end
  end

  using_input '010-edges/point-5-1-prototype.dot' do
    it 'lets you set attributes in the edge prototype (alphabeticesque)' do
      result.associate! 'a', 'b', attrs: { label: %<joe's mom: "jane"> }
      str = / label =.*/ =~ lines[-2] ? $& : ''
      str.should eql(%< label = "joe's mom: \\"jane\\"" ]>)
    end
    # 0747-0815 + 4hrs
    it 'lets you set attributes not yet in the edge prototype' do
      debug!
      result.associate! 'a', 'b', attrs: { politics: :radical }
      lines[-2].should eql(
"a -> b [ penwidth = 5 fontsize = 28 fontcolor = \"black\" label = \"e\" politics = radical ]"
                          )
    end
  end

  # --*--
  def lines
    result.unparse.split("\n")
  end
end
