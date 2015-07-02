require_relative 'test-support'

module Skylab::Basic::TestSupport::Pathname::Union

  ::Skylab::Basic::TestSupport::Pathname[ self ]

  include Constants

  extend TestSupport_::Quickie

  Home_ = Home_

  Subject_ = -> * x_a, & p do
    if x_a.length.nonzero? || p
      Home_::Pathname::Union[ * x_a, & p ]
    else
      Home_::Pathname::Union
    end
  end

  describe "[ba] Pathname::Union" do

    it "you can build up the union progressively, one path at at time" do
      u = Subject_[].new
      u.length.should eql 0
      u << ::Pathname.new( '/foo/bar' )  # (internally converted to string)
      u.length.should eql 1
      u << '/foo'
      u << '/biff/baz'
      u.length.should eql 3
    end
    context "you can build a union from a list of paths" do

      let :u do
        Subject_[ '/foo/bar', '/foo', '/biff/baz' ]
      end
      it "`normalize` eliminates logical redundancies in the union" do
        u.length.should eql 3
        e = u.normalize
        e.message_proc[].should eql 'eliminating redundant entry /foo/bar which is covered by /foo'
        u.length.should eql 2
      end
      it "`match` will result in the first path in the union that 'matches'" do
        x = u.match '/no'
        x.should eql nil
        x = u.match '/biff/baz'
        x.to_s.should eql '/biff/baz'
      end
      it "result of `match` is the node that matched" do
        x = u.match '/biff/baz/other'
        x.to_s.should eql '/biff/baz'
      end
    end
    it "like so" do
      u = Subject_[ '/foo/bar', '/foo/baz/bing', '/foo', '/a', '/a/b', '/a/b/c' ]
      u.normalize.message_proc[].should eql "eliminating redundant entries /a/b and /a/b/c which are covered by /a. eliminating redundant entries /foo/bar and /foo/baz/bing which are covered by /foo."
    end
  end
end
