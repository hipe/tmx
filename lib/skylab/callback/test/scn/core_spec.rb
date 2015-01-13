require_relative 'test-support'

module Skylab::Callback::TestSupport

  describe "[ca] Scn__" do

    it "aggregates other scanners, makes them behave as one sequence of scanners" do
      scn = Callback_::Scn.aggregate(
          LIB_.list_lib.line_stream( [ :a, :b ] ),
          LIB_.list_lib.line_stream( [] ),
          LIB_.list_lib.line_stream( [ :c ] ) )
      scn.count.should eql 0
      scn.gets.should eql :a
      scn.count.should eql 1
      scn.gets.should eql :b
      scn.count.should eql 2
      scn.gets.should eql :c
      scn.count.should eql 3
      scn.gets.should eql nil
      scn.count.should eql 3
    end
  end
end
