require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] models - test file context" do

    context "at present this exists only to assist shared setup of the" do

      before :all do
        X_xkcd_PATH = "test/1-abc-def/ghi-jkl_speg.kode"
      end

      it "and produce a stem like this" do
        o = Home_::Models_::TestFileContext.via_path X_xkcd_PATH
        expect( o.short_hopefully_unique_stem ).to eql "ad_gj"
      end
    end
  end
end
