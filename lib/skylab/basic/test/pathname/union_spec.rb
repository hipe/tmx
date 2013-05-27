require_relative 'test-support'

module Skylab::Basic::TestSupport::Pathname::Union

  ::Skylab::Basic::TestSupport::Pathname[ Union_TestSupport = self ]

  include CONSTANTS

  Basic = ::Skylab::Basic  # increase its visibility for below modules

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::Basic::Pathname::Union" do
    context "context 1" do
      Sandbox_1 = Sandboxer.spawn
      it "comprehensive usage example:" do
        Sandbox_1.with self
        module Sandbox_1
            # you can build up the union progressively, one path at at time:
          u = Basic::Pathname::Union.new
          u.length.should eql( 0 )
          u << ::Pathname.new( '/foo/bar' )  # (internally converted to string)
          u.length.should eql( 1 )
          u << '/foo'
          u << '/biff/baz'
          u.length.should eql( 3 )

            # `normalize` eliminates logical redundancies in the union:
          e = u.normalize
          e.message_function[].should eql( 'eliminating redundant entry /foo/bar which is covered by /foo' )
          u.length.should eql( 2 )

            # `match` will result in the first path in the union that 'matches'
          x = u.match '/no'
          x.should eql( nil )
          x = u.match '/biff/baz'
          x.to_s.should eql( '/biff/baz' )

            # the constituent paths that make up the union can "act like"
            # files or folders (leaves or branches) based on how the argument
            # string "treats" them - maybe better to think of them just as
            # nodes in a tree!

          x = u.match '/biff/baz/other'
          x.to_s.should eql( '/biff/baz' )
        end
      end
    end
    context "context 2" do
      Sandbox_2 = Sandboxer.spawn
      it "play with aggregated articulation" do
        Sandbox_2.with self
        module Sandbox_2
          u = Basic::Pathname::Union[ '/foo/bar', '/foo/baz/bing', '/foo', '/a', '/a/b', '/a/b/c' ]
          u.normalize.message_function[].should eql( "eliminating redundant entries /a/b and /a/b/c and /foo/bar and /foo/baz/bing which are covered by /a and /foo" )
        end
      end
    end
  end
end
