require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] queue [action queue] - args" do

    TS_[ self ]
    use :queue

    memoize_ :subject_class_ do

      class Q_AQ_Args_Cls_01

        include TS_::Queue::Methods_to_Make_a_Client_Class_Testable

        # <-

      def honka *a
        _push :HNKA, * a
      end

      def tonka
        _push :tnka
      end

      def flonka one, two=nil, three
        two ||= :TWO
        _push :flnk, one, two, three
      end

      def wonka x
        _push x
        if :three == x
          7
        else
          0
        end
      end

      self
      # ->
      end
    end

    it "loads" do

      subject_module_
    end

    it "passes along any args to a method" do

      action.enqueue_with_args :honka, :cream, :pie
      invoke
      @action.a.should eql %i( HNKA cream pie )
      @result.should be_zero
    end

    it "will call all the methods bound in the queue at call time" do

      action.enqueue :tonka
      @action.enqueue_with_args :flonka, :deef, :dorf
      @action.enqueue_with_args :honka
      invoke
      @action.a.should eql %i( tnka flnk deef TWO dorf HNKA )
      @result.should be_zero
    end

    it "but will short circuit if ever a method does not result in true" do

      action.enqueue_with_args :wonka, :one
      @action.enqueue_with_args :wonka, :two
      @action.enqueue_with_args :wonka, :three
      @action.enqueue_with_args :wonka, :four
      @action.enqueue_with_args :wonka, :five
      invoke
      @action.a.should eql %i( one two three )
      @result.should eql 7
    end
  end
end
