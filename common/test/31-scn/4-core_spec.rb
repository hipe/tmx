require_relative 'test-support'

module Skylab::Common::TestSupport

  describe "[co] scn (core)" do

    it "aggregates other scanners, makes them behave as one sequence of scanners" do

      scn_via = Home_.lib_.basic::List.line_stream.method :new

      scn = Home_::Scn.aggregate(
        scn_via[ [ :a, :b ] ],
        scn_via[ [] ],
        scn_via[ [ :c ] ],
      )

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
