require_relative '../test-support'

module Skylab::Tabular::TestSupport

  describe "[tab] magnetics - intro and simple" do

    it "here's an example of making a pipeline and then using it" do

      pipe = Home_::Pipeline.define do |o|
        o << :StringifiedTupleStream_via_MixedTupleStream
        o << :JustifiedPage_via_StringifiedTupleStream
        o << :LineStream_via_JustifiedPage
      end

      _tu_st = Home_::Common_::Stream.via_nonsparse_array(
        [ %w( Food Drink ), %w( donuts coffee ) ] )

      st = pipe.call _tu_st

      st.gets.should eql "|   Food  |   Drink |"
      st.gets.should eql "| donuts  |  coffee |"
      st.gets.should eql nil
    end
  end
end
