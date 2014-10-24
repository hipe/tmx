require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Parse

  describe "[mh] parse" do
    context "fuzzy matcher - partial match anchored to beginning" do
      Sandbox_2 = Sandboxer.spawn
      it "it's a proc that generates other procs" do
        Sandbox_2.with self
        module Sandbox_2
          p = Subject_[].fuzzy_matcher 3, 'foobie'
          p[ 'f' ].should eql( nil )
          p[ 'foo' ].should eql( true )
          p[ 'foob' ].should eql( true )
          p[ 'foobie-doobie' ].should eql( nil )
        end
      end

      context "hack label" do
        Sandbox_1 = Sandboxer.spawn
        it "like so -" do
          Sandbox_1.with self
          module Sandbox_1
            p = Subject_[].hack_label
            p[ :@foo_bar_x ].should eql "foo bar"
            p[ :some_method ].should eql "some method"
          end
        end
      end
    end
  end
end
