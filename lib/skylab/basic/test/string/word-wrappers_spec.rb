require_relative 'test-support'

module Skylab::Basic::TestSupport::String::WW

  ::Skylab::Basic::TestSupport::String[ self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[ba] string math word wrappers - both in parallel" do

    it "loads" do
      left_subject
    end

    it "loads (crazy)" do
      right_subject
    end

    it "two words" do
      ww = subject.new_with :margin, 'X', :width, 5, :downstream_yielder, []
      ww << 'foo bar'
      _y = ww.flush
      _y.should eql %w( Xfoo Xbar )
    end

    it "two words - we can't figure out how it works (crazy)" do
      ww = right_subject.curry 'X', 5, y=[]
      ww << 'foo bar'
      ww.flush
      y.should eql [ 'Xfoo bar' ]  # #todo
    end

    it "breaks on hyphens" do
      subject.with(
        :input_string, 'foo-bar', :width, 4, :downstream_yielder, [] ).
          should eql [ 'foo-', 'bar' ]
    end

    it "won't break (on hyphens) if it's perfect fit for the one line" do
      subject.with(
        :input_string, 'foo-bar', :width, 7, :downstream_yielder, [] ).
          should eql [ 'foo-bar' ]
    end

    it "words longer than target width must exceed it" do
      subject.with(
        :input_string, 'on tw threez fo fi',
        :width, 5, :downstream_yielder, [] ).should eql(
          [ 'on tw', 'threez', 'fo fi' ] )
    end

    it "amazingly, zero width doesn't bork" do
      subject.with( :input_string, 'fe fi fo', :width, 0,
        :downstream_yielder, [] ).should eql(
          [ 'fe', 'fi', 'fo' ] )
    end

    it "for now, negative width is borkless too" do
      subject.with( :input_string, 'fe fi fo', :width, -1,
        :downstream_yielder, [] ).should eql(
          [ 'fe', 'fi', 'fo' ] )
    end

    def left_subject
      Basic_::String.word_wrappers.calm
    end

    alias_method :subject, :left_subject

    def right_subject
      Basic_::String.word_wrappers.crazy
    end
  end
end
