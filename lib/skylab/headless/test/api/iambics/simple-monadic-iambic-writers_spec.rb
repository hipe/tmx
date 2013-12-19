require_relative 'test-support'

module Skylab::Headless::TestSupport::API::Iambics

  describe "[hl] API iambics - simple monadic iambic writers" do

    context "with three" do

      before :all do
        class Foo_Basic
          Headless::API::Simple_monadic_iambic_writers[ self,
            :jiang, :xiao, :qing ]

          def parse_this_passively * x_a
            absorb_iambic_passively x_a
            x_a
          end

          def parse_these_fully * x_a
            absorb_iambic_fully x_a
          end

          attr_reader :jiang, :xiao, :qing, :x_a
        end
      end

      it "loads" do
      end

      it "passive - ok on empty array, always sets @x_a" do
        a = foo.parse_this_passively
        a.should eql MetaHell::EMPTY_A_
        a.object_id.should eql foo.x_a.object_id
      end

      it "passive - parses a subset ('fully')" do
        foo = self.foo
        a = foo.parse_this_passively :jiang, :J, :qing, :Q
        a.should eql MetaHell::EMPTY_A_
        foo.jiang.should eql :J
        foo.qing.should eql :Q
      end

      it "order does not matter (for contiguous recognized terms)" do
        (( foo = self.foo )).parse_this_passively :qing, :Q, :xiao, :X
        foo.qing.should eql :Q ; foo.xiao.should eql :X
      end

      it "passive - stops at first unexpected arg" do
        foo = self.foo
        a = foo.parse_this_passively :xiao, :X, :wuu, :jiang, :J
        foo.xiao.should eql :X ; foo.jiang.should be_nil
        a.should eql %i( wuu jiang J )
      end

      let :foo do
        Foo_Basic.new
      end

      it "when 'fully' - works with subset" do
        x = (( foo = self.foo )).parse_these_fully :jiang, :J, :xiao, :X
        x.should be_nil
        foo.jiang.should eql :J ; foo.xiao.should eql :X
      end

      it "when 'fully' - unrecognzied term results in argument error" do
        foo = self.foo
        -> do
          foo.parse_these_fully :xiao, :X, :leung, :_never_see_
        end.should raise_error ::ArgumentError,
          /\Aunexpected iambic term ['":]leung['"]?\z/
      end
    end
  end
end
