require_relative 'test-support'
require_relative 'fixtures/neeples'

module ::Skylab::MetaHell::TestSupport::Boxxy

  describe "#{ MetaHell::Boxxy } load" do
    it "fetching the same nerk twice does not fail" do # catch an edge case
      Boxxy_TestSupport::Neeples.const_fetch :line_count
      Boxxy_TestSupport::Neeples.const_fetch :line_count
    end
  end
end
