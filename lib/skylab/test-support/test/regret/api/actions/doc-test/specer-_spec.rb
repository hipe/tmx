require_relative 'test-support'

module Skylab::TestSupport::TestSupport::Regret::API::Actions::DocTest::Specer_

  ::Skylab::TestSupport::TestSupport::Regret::API::Actions::DocTest[ Specer__TestSupport = self ]

  include CONSTANTS

  TestSupport = ::Skylab::TestSupport

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::TestSupport::Regret::API::Actions::DocTest::Specer_" do
    context "this is the first line of a comment block, to become a context desc" do
      Sandbox_1 = Sandboxer.spawn
      before :all do
        Sandbox_1.with self
        module Sandbox_1
          # this comment gets included in the output because it is indented
          # with four or more spaces, and its containing "SNIPPET" has the
          # magic equals predicate symbol in it somewhere.

          THIS_FILE_ = TestSupport::This_File[ __FILE__ ]
        end
      end
      it "this third line will become the desc for this example" do
        Sandbox_1.with self
        module Sandbox_1
          THIS_FILE_.contains( 'this comment gets included' ).should eql( true )
          THIS_FILE_.contains( '"this is the first line of a co' ).should eql( true )
          THIS_FILE_.contains( "you will #{ } not see" ).should eql( false )
          THIS_FILE_.contains( '"this is the first line of a co' ).should eql( true )
        end
      end
      it "note that we now strip trailing colons on these lines" do
        Sandbox_1.with self
        module Sandbox_1
          THIS_FILE_.contains( 'iling colons on these lines"' ).should eql( true )
        end
      end
    end
  end
end
