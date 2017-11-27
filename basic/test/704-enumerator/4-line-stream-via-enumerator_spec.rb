require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] list scanner for enumerator" do

    it "minimal monaic" do

      scn = subject do |y|
        y << :_one_
      end
      expect( scn.gets ).to eql :_one_
      expect( scn.gets ).to be_nil
      expect( scn.gets ).to be_nil
    end

    it "i can't believe this works" do

      scn = subject do |y|
        y << :a ; y << :b ; y << :c ; nil
      end
      expect( scn.gets ).to eql :a
      expect( scn.gets ).to eql :b
      expect( scn.gets ).to eql :c
      expect( scn.gets ).to be_nil
      expect( scn.gets ).to be_nil
    end

    def subject & p
      Home_::Enumerator::LineStream_by[ & p ]
    end
  end
end
