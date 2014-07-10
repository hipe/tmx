require_relative 'test-support'

module Skylab::TestSupport::TestSupport::Regret::API::Actions::DocTest

  ::Skylab::TestSupport::TestSupport::Regret::API::Actions[ self ]

  include CONSTANTS

  TestSupport = ::Skylab::TestSupport

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::TestSupport::Regret::API::Actions::DocTest" do
    context "probably no one will ever find a reason to call our API directly" do
      Sandbox_1 = Sandboxer.spawn
      before :all do
        Sandbox_1.with self
        module Sandbox_1
          API = Skylab::TestSupport::Regret::API
          # API.debug!
        end
      end
      it "which you can call `invoke` on" do
        Sandbox_1.with self
        module Sandbox_1
          API.invoke( :ping ).should eql( :hello_from_regret )
        end
      end
      it "from these comments you are reading" do
        Sandbox_1.with self
        module Sandbox_1
          here = API::Actions::DocTest.dir_pathname.sub_ext '.rb'
          output = TestSupport.dir_pathname.
            join( 'test/regret/api/actions/doc-test_spec.rb')
          stat = output.stat ; size1 = stat.size ; ctime1 = stat.ctime
            # (this test assumes one such file already exists)

          exitstatus = API.invoke :doc_test, pathname: here, output_path: output
            # the moneyshot. did it work?

          exitstatus.should eql( 0 )
            # exit status zero means success. it's the 1970's
          stat = output.stat
          stat.size.should eql( size1 )
            # the size should have stayed the same
          ( stat.ctime == ctime1 ).should eql( false )
            # but the ctimes should be different
        end
      end
    end
  end
end
