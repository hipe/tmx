require_relative 'test-support'

module Skylab::Permute::TestSupport

  describe "[pe] API" do

    extend TS_

    Zerk_lib_[].test_support::API[ self ]

    it "ping (as one inline test)" do

      call_API :ping

      expect_emission :info, :expression, :ping do |y|
        y == [ "hello from permute." ] || fail
      end

      expect_no_more_events
    end

    context "ping (as multitest context)" do

      call_by do
        call :ping
      end

      it "results in nothing" do
        root_ACS_result == nil || fail
      end

      it "expresses" do

        _be_this_emission = be_emission :info, :expression, :ping do |y|
          y == [ "hello from permute." ] || fail
        end

        only_emission.should _be_this_emission
      end
    end

    context "money." do

      call_by do
        call(
          :generate,
          :value_name_pairs, [[:A, :ltr], [:B, :ltr], [8, :num]],
        )
      end

      it "succeeds" do
        expect_trueish_result
      end

      it "the values are tuples (structs) with the members in order" do
        _sct = _result_as_array.fetch 0
        _sct.members == %i( ltr num ) || fail
      end

      it "look at all this money" do

        _act = _result_as_array.map( & :values )

        _act == [
          [ :A, 8 ],
          [ :B, 8 ],
        ] || fail
      end

      shared_subject :_result_as_array do
        root_ACS_result.to_a
      end

      def event_log  # i.e expect no events
        Home_::NOTHING_
      end
    end
  end
end
