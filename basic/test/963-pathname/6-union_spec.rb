require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] pathname union" do

    TS_[ self ]
    use :memoizer_methods

    it "you can build up the union progressively, one path at at time" do
      require 'pathname'
      u = Home_::Pathname::Union.new
      expect( u.length ).to eql 0
      u << ::Pathname.new( '/foo/bar' )  # (internally converted to string)
      expect( u.length ).to eql 1
      u << '/foo'
      u << '/biff/baz'
      expect( u.length ).to eql 3
    end

    context "you can build a union from a list of paths" do

      shared_subject :u do
        Home_::Pathname::Union[ '/foo/bar', '/foo', '/biff/baz' ]
      end

      it "`normalize` eliminates logical redundancies in the union" do
        expect( u.length ).to eql 3
        e = u.normalize
        expect( e.message_proc[] ).to eql 'eliminating redundant entry /foo/bar which is covered by /foo'
        expect( u.length ).to eql 2
      end

      it "`match` will result in the first path in the union that 'matches'" do
        x = u.match '/no'
        expect( x ).to eql nil
        x = u.match '/biff/baz'
        expect( x.to_s ).to eql '/biff/baz'
      end

      it "result of `match` is the node that matched" do
        x = u.match '/biff/baz/other'
        expect( x.to_s ).to eql '/biff/baz'
      end
    end

    it "like so" do
      u = Home_::Pathname::Union[ '/foo/bar', '/foo/baz/bing', '/foo', '/a', '/a/b', '/a/b/c' ]
      expect( u.normalize.message_proc[] ).to eql "eliminating redundant entries /a/b and /a/b/c which are covered by /a. eliminating redundant entries /foo/bar and /foo/baz/bing which are covered by /foo."
    end
  end
end
