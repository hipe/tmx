require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] box - as" do

    extend TS_
    use :box_support

    context "retrieve" do

      memoize_subject_ do

        bx = subject_.new
        bx.add :one, :One
        bx.add :three, :Three
        bx.add :five, :Five
        bx.algorithms
      end

      it "when you retrieve with |k, x| you get a [k, x] result" do
        subject_.retrieve do | k, v |
          :three == k
        end.should eql [ :three, :Three ]
      end

      it "when you retrieve with | x \ you get x back" do
        subject_.retrieve do | x |
          :Five == x
        end.should eql :Five
      end

      it "can be used like a complicated fetch" do

        k, x = subject_.retrieve -> k_, v_ { :three == k_ }

        k.should eql :three
        x.should eql :Three
      end

      it "the `else` proc works as proc" do

        subject_.retrieve( -> x { :NotThere == x }, -> { :alternate } ).
          should eql :alternate
      end

      it "the `else` proc works as block" do
        ( subject_.retrieve -> x { false } do :no end ).should eql :no
      end

      it "errmsg" do

        _rx = /\bvalue not found matching #<Proc@#{ ::Regexp.escape __FILE__ }:\d+>\z/
        -> do
          subject_.retrieve -> x { false }
        end.should raise_error ::KeyError, _rx
      end
    end

    it "to_hash" do

      subject_with_entries_( :a, :A, :b, :B ).
        algorithms.to_hash.should(
          eql a: :A, b: :B )
    end

    it "mutate_by_sorting_name_by" do

      bx = subject_with_entries_ :z, :Z, :x, :X, :y, :Y
      desired_order = [ :x, :z, :y ]
      bx.algorithms.mutate_by_sorting_name_by( & desired_order.method( :index ) )
      bx.instance_variable_get( :@a ).should eql desired_order
    end

    it "clear" do

      bx = subject_with_entries_ :a, :b
      bx.length.should eql 1
      bx.algorithms.clear.should be_nil
      bx.length.should be_zero
    end
  end
end
