require_relative 'test-support'

module Skylab::TestSupport::TestSupport::DocTest::Models::Front::Actions::Generate

  describe "[ts] DocTest::Models_::Front::Actions::Generate" do

    context "the `API` module is application programmer's interface to the API" do

      Sandbox_1 = Sandboxer.spawn

      before :all do
        Sandbox_1.with self
        module Sandbox_1
          API = TestSupport_::DocTest::API
        end
      end

      it "the minimal action that we can send to our API is the `ping` action" do
        Sandbox_1.with self
        module Sandbox_1
          API.call( :ping ).should eql :_hello_from_doc_test_
        end
      end

      it "from these comments you are reading" do
        Sandbox_1.with self
        module Sandbox_1
          here = DocTest_::Models_::Front::Actions::Generate.
            dir_pathname.sub_ext( '.rb' ).to_path

          output_pn = TestSupport_.dir_pathname.
            join( 'test/doc-test/models-front-actions/generate/integration/core_spec.rb' )

          stat = output_pn.stat ; size1 = stat.size ; ctime1 = stat.ctime
            # (this test assumes one such file already exists)

          result = API.call :generate,
            :output_path, output_pn.to_path,
            :upstream_path, here,
            :force,
            :output_adapter, :quickie

            # the moneyshot. did it work?

          result.should eql nil
            # for now this is nil on success

          stat = output_pn.stat

          stat.size.should eql size1
            # the size should have stayed the same
          ( stat.ctime == ctime1 ).should eql false
        end
      end
    end
  end
end
