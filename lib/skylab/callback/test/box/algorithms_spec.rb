require_relative 'test-support'

module Skylab::Callback::TestSupport::Box

  describe "[ca] box (algorithms)" do

    extend TS_

    context "retrieve" do

      memoize_subject do

        bx = Subject_[].new
        bx.add :one, :One
        bx.add :three, :Three
        bx.add :five, :Five
        bx.algorithms

      end

      it "when you retrieve with |k, x| you get a [k, x] result" do
        subject.retrieve do | k, v |
          :three == k
        end.should eql [ :three, :Three ]
      end

      it "when you retrieve with | x \ you get x back" do
        subject.retrieve do | x |
          :Five == x
        end.should eql :Five
      end

      it "can be used like a complicated fetch" do

        k, x = subject.retrieve -> k_, v_ { :three == k_ }

        k.should eql :three
        x.should eql :Three
      end

      it "the `else` proc works as proc" do

        subject.retrieve( -> x { :NotThere == x }, -> { :alternate } ).
          should eql :alternate
      end

      it "the `else` proc works as block" do
        ( subject.retrieve -> x { false } do :no end ).should eql :no
      end

      it "errmsg" do

        _rx = /\bvalue not found matching #<Proc@#{ ::Regexp.escape __FILE__ }:\d+>\z/
        -> do
          subject.retrieve -> x { false }
        end.should raise_error ::KeyError, _rx
      end
    end

    it "to_hash" do

      subject_with_entries( :a, :A, :b, :B ).
        algorithms.to_hash.should(
          eql a: :A, b: :B )
    end

    it "mutate_by_sorting_name_by" do

      bx = subject_with_entries :z, :Z, :x, :X, :y, :Y
      desired_order = [ :x, :z, :y ]
      bx.algorithms.mutate_by_sorting_name_by( & desired_order.method( :index ) )
      bx.instance_variable_get( :@a ).should eql desired_order
    end

    it "clear" do

      bx = subject_with_entries :a, :b
      bx.length.should eql 1
      bx.algorithms.clear.should be_nil
      bx.length.should be_zero
    end
  end
end
