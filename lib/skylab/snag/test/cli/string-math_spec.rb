require_relative 'test-support'

module Skylab::Snag::TestSupport::CLI::SM__

  ::Skylab::Snag::TestSupport::CLI[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  Snag_ = Snag_

  Subject_ = -> { Snag_::CLI.ellipsify }

  describe "[sg] CLI string math" do

    context "ellipsify - out of box usage" do

      it "empty empty" do
        subject( Snag_::EMPTY_S_ ).should eql Snag_::EMPTY_S_
      end

      _FIFTEEN = '012345678901234'
      it "on the money" do
        subject( _FIFTEEN ).should eql _FIFTEEN
      end

      it "work" do
        _sixteen = "#{ _FIFTEEN }5"
        _s = subject _sixteen
        _s.should eql '01234567890[..]'
      end

      def subject s
        Subject_[][ s ]
      end
    end

    context "ellipsify - provide args explicitly" do

      it "custom width" do
        Subject_[][ '012345', 5 ].should eql '0[..]'
      end

      it "custom glyph, use iambic args" do
        Subject_[].with( :input_string, '012345', :max_width, 5, :glyph, '*' ).
          should eql '0123*'
      end
    end

    context "ellipsify - curry with arglist" do

      it "curry with two args, call with one (just like a true proc)" do
        proc_like = Subject_[].curry[ '[...]', 6 ]
        proc_like[ '0123456' ].should eql '0[...]'
        proc_like[ '012345' ].should eql '012345'
      end

      it "curry with one arg, call with two (NOTE ORDER)" do
        proc_like = Subject_[].curry[ '•' ]
        proc_like[ '01234', 4 ].should eql '012•'
      end

      it "curry multiple times" do
        proc_one = Subject_[].curry[ 'A' ]
        proc_two = proc_one.curry[ 3 ]
        proc_two[ '0123' ].should eql '01A'
      end
    end

    context "ellipsify - curry with iambic" do

      it "ok" do
        proc_like = Subject_[].curry_with :max_width, 5
        proc_like[ '012345' ].should eql '0[..]'
      end

      it "curry multiple times" do
        proc_one = Subject_[].curry_with :glyph, '•'
        proc_two = proc_one.curry_with :max_width, 3
        proc_two[ '0123' ].should eql '01•'
      end
    end
  end
end
