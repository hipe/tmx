require_relative '../test-support'

module Skylab::Tabular::TestSupport

  describe "[tab] magnetics - intro and simple" do

    TS_[ self ]

    it "here's an example of making a pipeline and then using it" do

      pipe = Home_::Pipeline.define do |o|
        o << :StringifiedTupleStream_via_MixedTupleStream_and_Demo
        o << :JustifiedPage_via_StringifiedTupleStream_and_Demo
        o << :LineStream_via_JustifiedPage_and_Demo
      end

      _tu_st = Home_::Stream_[ [ %w( Food Drink ), %w( donuts coffee ) ] ]

      _st = pipe.call _tu_st

      want_these_lines_in_array_ _st do |y|
        y << '|   Food  |   Drink |'
        y << '| donuts  |  coffee |'
      end
    end

    # ==
    # ==
  end
end
