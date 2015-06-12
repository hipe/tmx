require_relative '../test-support'

module Skylab::FileMetrics::TestSupport

  describe "[fm] model - tree-branch [ struct ]" do

    extend TS_

    context "a produced subclass with one field" do

      with_klass do
        FM_::Model_::Tree_Branch.new :foo
      end

      it "trying to pass too many args - arg error" do
        cls = klass
        begin
          cls.new :one, :two
        rescue ::ArgumentError => e
        end
        e.message.should match %r(\bwrong number.+\(2 for 1\))
      end

      it "trying to pass too few args - ok, you get nil (and reader)" do
        me = klass.new
        me.foo.should eql( nil )
      end
    end

      it "unlike struct, it can subclass" do

        kls1 = ::Class.new( _subject_class.new( :foo, :bar ) )

        Sandbox_.kiss kls1

        kls2 = Sandbox_.kiss( kls1.subclass :wing, :wang )

        kls2.const_get( :BX____ ).a_.should eql(

          [ :foo, :bar, :wing, :wang ] )

        o2 = kls2.new 'fOo', 'bAr', 'wIng', 'wAng'

        o2.bar.should eql 'bAr'

        o2.wang.should eql 'wAng'
      end

    def _subject_class
      FM_::Model_::Tree_Branch
    end
  end
end
