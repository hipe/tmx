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
      expect( o.a ).to eql :a
      expect( o.b ).to eql nil
      expect( o.slug ).to eql :x

    end
  end
end
