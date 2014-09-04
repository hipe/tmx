require_relative 'test-support'

module Skylab::TanMan::TestSupport::Models::Association

  describe "[tm] Models::Association associate", wip: true do

    extend TS_

    using_input '../../node/fixtures/simple-prototype-and-graph-with/zero-but-with-leading-space.dot' do
      it 'associates nodes when neither exists, creating them' do
        controller = self.controller
        o = controller.associate! 'one', 'two'
        o.unparse.should eql( 'one -> two' )
        lines[-3..-1].should eql( [ "two [label=two]", "one -> two", "}" ] )
      end
    end

    using_input '2-nodes-0-edges.dot' do
      it 'associates when first exists, second does not' do
        r = controller.associate! 'alpha', 'peanut gallery'
        lines[-3..-1].should eql(
          ['peanut [label="peanut gallery"]', 'alpha -> peanut', '}' ])
        r.should be_respond_to( :source_node_id )   # edge statement
      end
    end

    using_input '2-nodes-1-edge.dot' do
      it 'does not associate again redundantly' do
        result._edge_stmts.to_a.length.should eql( 1 )
        controller.associate! 'alpha', 'gamma'
        result._edge_stmts.to_a.length.should eql( 1 )
      end
    end

    using_input '0-nodes-3-edges.dot' do
      it "adds edge statements in unobtrusive lexical-esque order, #{
           } with taxonomy and proximity" do
        result._edge_stmts.to_a.length.should eql( 3 )
        result._node_stmts.to_a.length.should eql( 0 )
        controller.associate! 'feasly', 'teasly'
        result._edge_stmts.to_a.length.should eql( 4 )
        result._node_stmts.to_a.length.should eql( 2 ) # it created one that it ..
        exp = <<-O.unindent.strip
          */
          feasly [label=feasly]
          teasly [label=teasly]
          beasly -> teasly
          feasly -> teasly
          gargoyle -> flargoyle
          ainsly -> fainsly
          }
        O
        act = lines[ -8..-1 ].join( "\n" ).strip
        act.should eql( exp )
      end
    end

    using_input 'point-5-1-prototype.dot' do
      it 'uses any edge prototype called "edge_stmt"' do
        controller.associate! 'foo', "bar's mother"
        lines[-2].should eql(%(foo -> bar [ penwidth = 5 fontsize = 28 #{
          }fontcolor = "black" label = "e" ]))
      end
    end



    using_input 'point-5-2-named-prototypes.dot' do

      -> do
        msg = 'the stmt_list in xyzzy.dot has no prototype named "clancy"'

        it "if weird prototype name - #{ msg }" do
          begin
            controller.associate! 'a', 'b', prototype: :clancy
          rescue ::RuntimeError => e
          end
          e.message.should eql( msg )
        end
      end.call


      it 'lets you choose which of several edge prototypes' do
        controller.associate! 'c', 'd', prototype: :fancy
        controller.associate! 'b', 'a', prototype: :boring
        lines[-7..-2].should eql(
          ["a [label=a]", "b [label=b]", "c [label=c]", "d [label=d]",
          "b -> a [this=is not=fancy]", "c -> d [this=style is=fancy]"] )
      end
    end


    using_input 'point-5-1-prototype.dot' do

      it 'lets you set attributes in the edge prototype (alphabeticesque)' do
        controller.associate! 'a', 'b', attrs: { label: %<joe's mom: "jane"> }
        str = / label =.*/ =~ lines[-2] ? $& : ''
        str.should eql( %< label = "joe's mom: \\"jane\\"" ]> )
      end

      it 'lets you set attributes not yet in the edge prototype' do
        controller.associate! 'a', 'b', attrs: { politics: :radical }
        lines[-2].should eql(
          "a -> b [ penwidth = 5 fontsize = 28 #{
            }fontcolor = \"black\" label = \"e\" politics = radical ]"
        )
      end
    end
  end
end
