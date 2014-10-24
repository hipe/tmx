require_relative 'test-support'

module Skylab::Headless::TestSupport::API::Iambics

  describe "[hl] API iambics - reflectivity via 'fetch_parameter'" do

    context "monadic two with custom meta-parameter name" do

      before :all do
        class Two_RVFP
          Headless_::API::Iambic_parameters[ self,
            :reflection_method_stem, :term,
            :params, :one, :two ]
        end
      end

      it "loads" do
      end

      it "fetch existant - o" do
        x = Two_RVFP.fetch_term :two
        x.param_i.should eql :two
      end

      it "fetch existant with an else block - o" do
        x = Two_RVFP.fetch_term :one do :never_see end
        x.param_i.should eql :one
      end

      it "fetch nonexistant without an else block - (LEVENSHTEIN YAY.) X" do
        _s = "there is no such term 'three' - did you mean 'one' or 'two'?"
        -> do
          Two_RVFP.fetch_term :three
        end.should raise_error ::NameError, _s
      end

      it "fetch nonexistant with an else block - o" do
        x = Two_RVFP.fetch_term :four do :x end
        x.should eql :x
      end
    end
  end
end
