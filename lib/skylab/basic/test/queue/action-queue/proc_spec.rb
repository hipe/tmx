require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] queue [action queue] - proc" do

    extend TS_
    use :queue

    memoize_ :subject_class_ do

      class Q_AQ_Proc_Cls_01

        include TS_::Queue::Methods_to_Make_a_Client_Class_Testable

        # <-

      def fapple
        emit_info_line "yes."
        :_hi_
      end

      self

      # ->
      end
    end

    it "you can enqueue a single proc" do
      yes = :no
      action.enqueue -> { yes = :yes ; 0 }
      invoke
      expect_no_more_serr_lines
      @result.should be_zero
      yes.should eql :yes
    end

    it "with multiple procs, if first one is not OK, it is result" do
      action.enqueue -> { 99  }
      action.enqueue -> { 0  }
      invoke
      expect_no_more_serr_lines
      @result.should eql 99
    end

    it "but as long as things result in OK they are executed" do
      y = []
      ok = 0
      action.enqueue -> { y << :_one_ ; ok }
      @action.enqueue -> { y << :_two_ ; ok }
      @action.enqueue -> { y << :_three_ ; 2 }
      @action.enqueue -> { y << :_four__ ; ok }
      invoke
      y.should eql %i( _one_ _two_ _three_ )
      expect_no_more_serr_lines
      @result.should eql 2
    end

    # :+#tombstone: (2x) when the invoke args were passed to the last queue

    def expect_no_more_serr_lines
      NIL_  # ..
    end

    # :+#tombstone: oldschool isomorphic args
  end
end
