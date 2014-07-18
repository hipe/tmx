require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Parse

  describe "[mh] Parse" do
    context "hack label" do
      Sandbox_1 = Sandboxer.spawn
      it "like so -" do
        Sandbox_1.with self
        module Sandbox_1
          P = MetaHell::Parse::Hack_label_
          P[ :@foo_bar_x ].should eql( "foo bar" )
          P[ :some_method ].should eql( "some method" )
        end
      end
    end
    context "fuzzy matcher - partial match anchored to beginning" do
      Sandbox_2 = Sandboxer.spawn
      it "it's a proc that generates other procs" do
        Sandbox_2.with self
        module Sandbox_2
          P = MetaHell::Parse::Fuzzy_matcher_
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
