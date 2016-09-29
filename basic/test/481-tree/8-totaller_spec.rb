require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] tree - totaller" do

    before :all do

      T_T_1 = Home_::Tree::Totaller.new :a, :b
    end

    it "makes" do
    end

    it "builds" do

      o = T_T_1.new
      o.slug = :x
      o.a = :a
      o.a.should eql :a
      o.b.should eql nil
      o.slug.should eql :x

    end
  end
end
