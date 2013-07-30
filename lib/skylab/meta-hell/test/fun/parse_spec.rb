require_relative 'test-support'

module Skylab::MetaHell::TestSupport::FUN::Parse

  ::Skylab::MetaHell::TestSupport::FUN[ Parse_TestSupport = self ]

  include CONSTANTS

  MetaHell = ::Skylab::MetaHell

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::MetaHell::FUN::Parse" do
    context "fuzzy matcher" do
      Sandbox_1 = Sandboxer.spawn
      it "is a currier - it's a proc that generates other procs" do
        Sandbox_1.with self
        module Sandbox_1
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
