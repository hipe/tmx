require_relative 'test-support'

module Skylab::Basic::TestSupport::List::Scanner::For

  describe "[ba] list scanner for enumerator" do

    it "minimal monaic" do
      scn = Basic_::List::Scanner::For.block do |y|
        y << :_one_
      end
      scn.gets.should eql :_one_
      scn.gets.should be_nil
      scn.gets.should be_nil
    end

    it "i can't believe this works" do
      scn = Basic_::List::Scanner::For.block do |y|
        y << :a ; y << :b ; y << :c ; nil
      end
      scn.gets.should eql :a
      scn.gets.should eql :b
      scn.gets.should eql :c
      scn.gets.should be_nil
      scn.gets.should be_nil
    end
  end
end
