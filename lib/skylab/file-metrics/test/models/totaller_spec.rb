require_relative '../test-support'

module Skylab::FileMetrics::TestSupport

  describe "[fm] models - totaller" do

    before :all do

      FMMT_One = FM_::Models_::Totaller.new :a, :b
    end

    it "makes" do
    end

    it "builds" do

      o = FMMT_One.new
      o.slug = :x
      o.a = :a
      o.a.should eql :a
      o.b.should eql nil
      o.slug.should eql :x

    end
  end
end
