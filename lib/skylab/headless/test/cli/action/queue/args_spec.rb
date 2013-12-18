require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI::Action::Queue_Args__

  ::Skylab::Headless::TestSupport::CLI::Action[ TS__ = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "[hl] CLI action queue - args" do

    extend TS__

    with_action_class :Wappel do
      def default_action_i
        :wipple
      end
      def honka *a
        _push :HNKA, * a ; :_hnka_
      end
      def tonka
        _push :tnka ; true
      end
      def donka
        :_becca_stahp_
      end
      def flonka one, two=nil, three
        two ||= :TWO
        _push :flnk, one, two, three ; true
      end
      def wonka x
        _push x ; :three != x
      end
      public :enqueue, :enqueue_with_args
      attr_reader :a
      def _push * x_a
        ( @a ||= [] ).concat x_a ; nil
      end
    end

    it "passes along any args to a method" do
      action.enqueue_with_args :honka, :cream, :pie
      invoke
      @action.a.should eql %i( HNKA cream pie )
      @result.should eql :_hnka_
    end

    it "call many methods (via two means), last one gets the args if.." do
      action.enqueue :tonka
      @action.enqueue_with_args :flonka, :deef, :dorf
      action.enqueue_with_args :honka
      invoke %w( wat fun )
      @action.a.should eql %i( tnka flnk deef TWO dorf HNKA )
      @result.should eql :_hnka_
    end

    it "but will short circuit if ever a method does not result in true" do
      action.enqueue_with_args :wonka, :one
      @action.enqueue_with_args :wonka, :two
      @action.enqueue_with_args :wonka, :three
      @action.enqueue_with_args :wonka, :four
      @action.enqueue_with_args :wonka, :five
      invoke %w( any number of args )
      @action.a.should eql %i( one two three )
    end
  end
end
