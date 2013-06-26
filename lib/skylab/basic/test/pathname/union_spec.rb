require_relative 'test-support'

module Skylab::Basic::TestSupport::Pathname::Union

  ::Skylab::Basic::TestSupport::Pathname[ Union_TestSupport = self ]

  include CONSTANTS

  Basic = ::Skylab::Basic  # increase its visibility for below modules

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::Basic::Pathname::Union" do
    context "progressive construction" do
      Sandbox_1 = Sandboxer.spawn
      it "you can build up the union progressively, one path at at time" do
        Sandbox_1.with self
        module Sandbox_1
          u = Basic::Pathname::Union.new
          u.length.should eql( 0 )
          u << ::Pathname.new( '/foo/bar' )  # (internally converted to string)
          u.length.should eql( 1 )
          u << '/foo'
          u << '/biff/baz'
          u.length.should eql( 3 )
        end
      end
    end
    context "`normalize` eliminates logical redundancies in the union" do
      Sandbox_2 = Sandboxer.spawn
      it "like so" do
        Sandbox_2.with self
        module Sandbox_2
          u = Basic::Pathname::Union[ '/foo/bar', '/foo', '/biff/baz' ]
          u.length.should eql( 3 )
          e = u.normalize
          e.message_function[].should eql( 'eliminating redundant entry /foo/bar which is covered by /foo' )
          u.length.should eql( 2 )
        end
      end
    end
    context "`match` will result in the first path in the union that 'matches'" do
      Sandbox_3 = Sandboxer.spawn
      it "like so" do
        Sandbox_3.with self
        module Sandbox_3
          u = Basic::Pathname::Union[ '/foo/bar', '/foo', '/biff/baz' ]
          x = u.match '/no'
          x.should eql( nil )
          x = u.match '/biff/baz'
          x.to_s.should eql( '/biff/baz' )
        end
      end
    end
    context "if you use the result of `match` be aware it may be counter-intuitive." do
      Sandbox_4 = Sandboxer.spawn
      it "result of `match` is the node that matched" do
        Sandbox_4.with self
        module Sandbox_4
          u = Basic::Pathname::Union[ '/foo/bar', '/foo', '/biff/baz' ]
          x = u.match '/biff/baz/other'
          x.to_s.should eql( '/biff/baz' )
        end
      end
    end
    context "for fun, `message_function` may play with `aggregated articulation`" do
      Sandbox_5 = Sandboxer.spawn
      it "like so" do
        Sandbox_5.with self
        module Sandbox_5
          u = Basic::Pathname::Union[ '/foo/bar', '/foo/baz/bing', '/foo', '/a', '/a/b', '/a/b/c' ]
          u.normalize.message_function[].should eql( "eliminating redundant entries /a/b and /a/b/c and /foo/bar and /foo/baz/bing which are covered by /a and /foo" )
        end
      end
    end
  end
end
