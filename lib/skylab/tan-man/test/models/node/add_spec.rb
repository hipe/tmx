require_relative 'test-support'

module  Skylab::TanMan::TestSupport::Models::Node

  # *Partially* Quickie compatible oh my!

  describe "#{ Skylab::TanMan::Models::Node } adding" do

    extend ::Skylab::TanMan::TestSupport::Models::Node

    using_input 'simple-prototype-and-graph-with/zero.dot' do
      it 'adds a node to zero nodes' do
        result.nodes.should eql( [] )
        controller.node! 'feep'
        a = result.nodes
        a.length.should eql( 1 )
        result.stmt_list.unparse.should eql( "feep [label=feep]\n" )
      end

      it "creates unique but natural node_ids" do
        controller.node! 'milk the cow'
        controller.node! 'milk the cat'
        controller.node! 'MiLk the catfish'
        result.nodes.map(& :node_id).should eql( [:milk_3, :milk_2, :milk] )
        a = result.nodes.map(& :label)
        a.shift.should eql( 'MiLk the catfish' )
        a.shift.should eql( 'milk the cat' )
        a.shift.should eql( 'milk the cow' )
      end
    end



    using_input(
      "big-ass-prototype-with-html-in-it-watchya-gonna-do-now-omg.dot" ) do

      -> do
        msg = <<-O.unindent.strip
          html-escaping support is currently very limited. #{
          }the following characters are not yet supported: "\\t" (009), #{
          }"\\n" (010), "\\x7F" (127)
        O

        it "when you try to use weird chars for labels - #{
          }\"#{ msg[ 0..96 ] }[..]\"" do

          begin
            controller.node! "\t\t\n\x7F"
          rescue ::RuntimeError => e
          end

          e.message.should eql( msg )
        end
      end.call



      -> do
        input = 'joe\'s "mother" & i <wat>'
        output = 'joe&apos;s &quot;mother&quot; &amp; i &lt;wat&gt;'

        it "it will escape some chars - #{
          }this:(#{ input }) becomes : #{ output }" do

          o = controller.node! input
          big_html_string = o.unparse

          big_html_string.include?( output ).should eql(true)
        end
      end.call
    end
  end
end
