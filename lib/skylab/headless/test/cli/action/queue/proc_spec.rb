require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI::Action::Queue_Procs__

  ::Skylab::Headless::TestSupport::CLI::Action[ TS__ = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "[hl] CLI action queue - procs", ok: true do

    extend TS__

    with_action_class :Fippel do
      def default_action_i
        :fapple
      end
      def fapple
        emit_info_line "yes."
        :_hi_
      end
      public :enqueue
    end

    it "you can enqueue a single proc" do
      action.enqueue -> { :_hello_there_ }
      invoke
      expect_no_more_serr_lines
      @result.should eql :_hello_there_
    end

    it "with multiple procs, if first one is not OK, it is result" do
      action.enqueue -> { :_one_  }
      action.enqueue -> { :_two_  }
      invoke
      expect_no_more_serr_lines
      @result.should eql :_one_
    end

    it "but as long as things result in OK they are executed" do
      y = []
      action.enqueue -> { y << :_one_ ; _OK }
      @action.enqueue -> { y << :_two_ ; _OK }
      @action.enqueue -> { y << :_three_ ; :__OK__ }
      @action.enqueue -> { y << :_four__ ; _OK }
      invoke
      y.should eql %i( _one_ _two_ _three_ )
      expect_no_more_serr_lines
      @result.should eql :__OK__
    end

    let :_OK do
      Headless::CLI::Action::OK_  # do this late, don't load it early
    end

    it "when queue is only one proc, will take argv args" do
      y = []
      action.enqueue -> one, two, three=nil { y << [ one, two, three ] ; :x }
      invoke 'ONE', 'TWO'
      y.should eql [ [ 'ONE', 'TWO', nil ] ]
      expect_no_more_serr_lines
      @result.should eql :x
    end

    it "when multiple procs, only last one takes argv ags" do
      y = []
      action.enqueue -> { y << :hi; _OK }
      action.enqueue -> hey { y << hey ; :_hey_ }
      debug!
      invoke 'HEY'
      y.should eql [ :hi, 'HEY' ]
      @result.should eql :_hey_
    end

    context "complaining about arguments" do

      before :each do
        @y = []
        action.enqueue( -> foo=nil, bar=nil, baz, biff do
          @y.push foo, bar, baz, biff ; :_yes_
        end )
      end

      it "complaining about arguments (just one problem though)" do
        invoke 'only-one'
        expect :styled, /\bexpecting: <biff>\z/
        expect :styled, /\busage: yerp fippel\z/
        expect :styled, /\Ause\b.+\b for help\b/
        expect_failed
      end

      it "when have both" do
        invoke 'one', 'two'
        @y.should eql [ nil, nil, 'one', 'two' ]
        expect_no_more_serr_lines
        @result.should eql :_yes_
      end
    end
  end
end
