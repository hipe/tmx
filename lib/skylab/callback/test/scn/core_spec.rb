require_relative 'test-support'

module Skylab::Callback::TestSupport

  describe "[ca] Scn__" do

    it "aggregates other scanners, makes them behave as one sequence of scanners" do

      lib = LIB_.basic::List

      scn = Callback_::Scn.aggregate(
        lib.line_stream( [ :a, :b ] ),
        lib.line_stream( [] ),
        lib.line_stream( [ :c ] ) )

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
