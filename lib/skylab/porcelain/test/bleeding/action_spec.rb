require_relative 'test-support'

module Skylab::Porcelain::Bleeding::TestSupport
  describe "#{Bleeding::ActionModuleMethods}" do
    extend ModuleMethods
    include InstanceMethods
    last = 0
    let(:base_module) { Skylab::Porcelain::Bleeding.const_set("XyzzyB#{last += 1}", Module.new) }
    with_namespace 'herp-derp'
    context "You can't have an action that is a completely blank slate class because that" do
      with_action 'ferp-merp'
      klass(:HerpDerp__FerpMerp) { }
      let(:subject) { -> { fetch } }
      specify { should raise_error(NameError, /undefined method `invoke' for class.+FerpMerp/) }
    end
    context "So if you make an action class called FerpMerp that does nothing but define invoke(), it" do
      with_action 'ferp-merp'
      klass(:HerpDerp__FerpMerp) do
        def invoke ; end
      end
      specify { should be_action(aliases: ['ferp-merp']) }
    end
    context "If you make an action class that does nothing but extend #{Bleeding::ActionModuleMethods}, it" do
      with_action 'ferp-merp'
      klass(:HerpDerp__FerpMerp) do
        extend Bleeding::ActionModuleMethods
      end
      specify { should be_action(aliases: ['ferp-merp']) }
    end
    context "Once you decide to extend (or subclass a class that extends) this, the magic really starts to happen!!!!!!" do
      context "For example, you can use the desc() method to describe your interface element" do
        context "with just one line" do
          with_action 'ferp-merp'
          klass(:HerpDerp__FerpMerp) do
            extend Bleeding::ActionModuleMethods
            desc 'zerp'
          end
          specify { should be_action(desc: ['zerp']) }
        end
      end
    end
    context "#{Bleeding::ActionModuleMethods} desc (an inheritable attribute)" do
      klass(:Base) do
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
        klass(:Child, extends: :Base) ; let(:child) { send(:Child) }
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
    end
  end
end
