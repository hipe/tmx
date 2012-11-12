require_relative 'test-support'

module Skylab::Porcelain::TestSupport::Bleeding::Action # #po-008
  describe "desc, an inheritable attribute of #{Bleeding::ActionModuleMethods}" do
    extend Action_TestSupport
    incrementing_anchor_module!
    klass :Base do
      extend Bleeding::ActionModuleMethods
    end
    let(:base) { send(:Base) }
    context "All classes that extend ActionModuleMethods have a desc that by default" do
      let(:subject) { base.desc }
      specify { should eql([]) }
      it("have a consistent oid") { base.desc.object_id.should eql(base.desc.object_id) }
    end
    it "You can add a string of desc with the DSL, which will change the object_id of the desc" do
      oid = base.desc.object_id
      base.desc 'foo'
      base.desc.should eql(['foo'])
      base.desc.object_id.should_not eql(oid)
    end
    it "You can mutate desc with the familiar array accessors (won't change oid)" do
      base.desc 'foo'
      oid = base.desc.object_id
      base.desc.concat(['bar', 'baz'])
      base.desc.should eql(['foo', 'bar', 'baz'])
      base.desc.object_id.should eql(oid)
    end
    context "When you have a child class of a base class with a desc" do
      klass( :Child, extends: :Base ) ; let( :child ) { send(:Child) }
      before(:each) do
        base.desc 'foo', 'bar'
      end
      it "the desc of the child will start out as the same as that of the base at that time" do
        child.desc.should eql(['foo', 'bar'])
      end
      it "but it is a different object, and won't pick up subsequent changes in the base desc" do
        base.desc 'bazzo'
        coid = child.desc.object_id
        coid.should_not eql(base.desc.object_id)
        child.desc.should eql(['foo', 'bar', 'bazzo'])
        base.desc 'bizzo'
        child.desc.should eql(['foo', 'bar', 'bazzo'])
        child.desc.object_id.should eql(coid)
      end
      it "and most importantly, the partent desc won't pick up subequent changes in the child" do
        child.desc 'bingo'
        child.desc.should eql(['foo', 'bar', 'bingo'])
        base.desc.should eql(['foo', 'bar'])
      end
    end
    context "(bugfix: be sure that flyweighting doesn't interfere)" do
      let(:emit_spy) { ::Skylab::TestSupport::EmitSpy.new }
      klass :CLI, extends: Bleeding::Runtime do
        def initialize rt
          @rt = rt
        end
        def emit(t, s)
          @rt.emit(SimplifiedEvent.new(t, unstylize(s)))
        end
        module self::Actions ; end
        class self::Action
          extend Bleeding::ActionModuleMethods
        end
        class self::Actions::Ferp < self::Action
          desc "wing"
        end
        class self::Actions::Derp < self::Action
          desc "ding"
        end
      end
      it "it should not have flyweighting fuck this whole thing up", f:true do
        send(:CLI).new(emit_spy).invoke(['-h'])
        emit_spy.stack.map(&:message).grep(/^ *ferp\b/).first.should be_include('wing')
        emit_spy.stack.map(&:message).grep(/^ *derp\b/).first.should be_include('ding')
      end
    end
  end
end
