require_relative 'test-support'

module Skylab::MetaHell::TestSupport::FUN::Parse

  ::Skylab::MetaHell::TestSupport::FUN[ self ]

  include CONSTANTS

  MetaHell = ::Skylab::MetaHell

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::MetaHell::FUN::Parse" do
    context "hack label" do
      Sandbox_1 = Sandboxer.spawn
      it "like so -" do
        Sandbox_1.with self
        module Sandbox_1
          P = MetaHell::FUN::Parse::Hack_label_
          P[ :@foo_bar_x ].should eql( "foo bar" )
          P[ :some_method ].should eql( "some method" )
        end
      end
    end
    context "fuzzy matcher" do
      Sandbox_2 = Sandboxer.spawn
      it "is a currier - it's a proc that generates other procs" do
        Sandbox_2.with self
        module Sandbox_2
          P = MetaHell::FUN::Parse::Fuzzy_matcher_
          Q = P[ 3, 'foobie' ]

          Q[ 'f' ].should eql( nil )
          Q[ 'foo' ].should eql( true )
          Q[ 'foob' ].should eql( true )
          Q[ 'foobie-doobie' ].should eql( nil )
        end
      end
    end
  end
end
