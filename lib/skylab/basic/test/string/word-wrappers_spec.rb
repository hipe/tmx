require_relative 'test-support'

module Skylab::Basic::TestSupport::String::WW

  ::Skylab::Basic::TestSupport::String[ self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[ba] string math word wrappers - both in parallel" do

    it "loads" do
      left_subject
    end

    it "loads" do
      right_subject
    end

    it "two words" do
      ww = left_subject.new 'X', 5, y=[]
      ww << 'foo bar'
      ww.flush
      y.should eql %w( Xfoo Xbar )
    end

    it "two words - we can't figure out how it works" do
      ww = right_subject.curry 'X', 5, y=[]
      ww << 'foo bar'
      ww.flush
      y.should eql [ 'Xfoo bar' ]  # #todo
    end

    def left_subject
      Basic_::String.word_wrappers.calm
    end

    def right_subject
      Basic_::String.word_wrappers.crazy
    end
  end
end
