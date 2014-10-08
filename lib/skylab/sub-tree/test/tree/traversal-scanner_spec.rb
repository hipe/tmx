require_relative 'test-support'

module Skylab::SubTree::TestSupport::Tree::Traversal_Scanner

  ::Skylab::SubTree::TestSupport::Tree[ self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "[st] tree traversal scanner" do

    it "3 node triangle" do
      tree = fp 'a/b', 'a/c'
      tree = tree.fetch_only_child
      scn = tree.get_traversal_scanner
      y = [ ]
      while (( card = scn.gets ))
        n = card.node
        y << "#{ card.prefix[] }#{ n.any_slug }"
      end
      ( y * '|' ).should eql( "  a|   ├b|   └c" )
    end

    it "3 deep stem" do
      tree = fp 'a/b/c'
      tree = tree.fetch_only_child
      scn = tree.get_traversal_scanner
      a = [ ]
      while (( card = scn.gets ))
        a << "#{ card.prefix[] }#{ card.node.any_slug }"
      end
      a[ 1 .. -1 ].should eql( ["   └b", "     └c"] )
    end

    it "vert. runs" do
      exp_a = [ [ 1, "  z" ], [ 4, "   │   └sabblewood" ],
        [ 7, "   │ │ └beef" ] ]
      tree = fp 'z/hufflbuff/ravendoor', 'z/hufflbuff/ravendoor/sabblewood',
        'z/snaggoletoogh/liverwords',
        'z/snaggoletoogh/liverwords/beef', 'z/snaggoletoogh/jonkerknocker',
        'z/hufflebuff/nikclebonkers', 'z/jipsaw'
      tree = tree.fetch_only_child
      scn = tree.get_traversal_scanner
      wait, exp = exp_a.shift
      while (( card = scn.gets ))
        n = card.node
        line = "#{ card.prefix[] }#{ n.any_slug }"
        if wait == scn.count
          line.should eql( exp )
          wait, exp = exp_a.shift
          wait or break
        end
      end
    end

    def get_enumerator
      ::Enumerator::Yielder.new( & TestSupport.debug_IO.stderr.method( :puts ) )
    end

    def fp * x_a
      Subject_[].from :paths, x_a
    end
  end
end
