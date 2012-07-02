# encoding: UTF-8
require_relative '../test-support'

module Skylab::Porcelain::Bleeding::TestSupport
  describe "So check this shit out with #{Bleeding::ActionModuleMethods} summary (an inheritable attribute):" do
    extend ModuleMethods ; include InstanceMethods
    _hack = nil ; _last = 0
    let(:base_module) { Skylab::Porcelain::Bleeding.const_set("XyzzyC#{_last += 1}", Module.new) }
    klass(:Base) do
      extend Bleeding::ActionModuleMethods
      instance_exec(& _hack.desc_block)
    end ; let(:base) { _hack = self ; send(:Base) }
    def self.desc *a
      let(:desc_block) { ->{ desc(*a) } }
    end
    let(:subject) { base.summary }
    context "By default the summary is the first few lines of the desc.  With a desc of" do
      context "three lines" do
        desc 'foo', 'bar', 'baz'
        it('the summary is the first two lines'){ should eql(['foo', 'bar']) }
      end
      context "two lines" do
        desc 'foo', 'biz'
        it('the summary is all of the desc'){ should eql(['foo', 'biz']) }
      end
      context "one line" do
        desc 'foo'
        it('the summary is all of the desc') { should eql(['foo']) }
      end
      context "With no desc indicated at all" do
        let(:desc_block) { ->{ } } # no-op
        it("ain't no summary when it rains") { should eql([]) }
      end
    end
    context "Child classes inherit parent summaries in an intuitive manner" do
      klass(:Child, extends: :Base) do
        instance_exec(& _hack.child_desc_block)
      end ; let(:child) { _hack = self ; send(:Child) }
      def self.child_desc *a
        let(:child_desc_block) { ->{ desc(*a) } }
      end
      let(:subject) { child.summary }
      context "So, as the summary is by default the above described function" do
        context "and parent has desc" do
          desc 'foo', 'bar'
          context "and child doesn't change its desc" do
            let(:child_desc_block) { ->{ } } # no-op
            it("then it inherits parent desc and hence parent summary") { should eql(['foo', 'bar']) }
          end
          context "but child has no desc by explicitly erasing it" do
            let(:child_desc_block) { ->{ self.desc.clear } }
            it("then child has no summary")  { should eql([]) }
          end
          context "and if child sets its desc" do
            let(:child_desc_block) { ->{ self.desc.replace( ['bing'] ) } }
            it("then it inherits the parent summary function hence uses child desc") { should eql(['bing']) }
          end
        end
      end
    end
    context "The RAW POWER of this is UNLEASHED when you have inherited useful functions",f:true do
      desc 'never see', 'base class'
      klass(:Child, extends: :Base) do
        desc "ok go"
        summary { ["#{aliases.first}<-->#{desc.last.upcase.gsub('á', 'Á')}"] }
      end
      klass(:SubChild1, extends: :Child) do
        desc "pootenany", "whootenany"
      end
      klass(:SubChild2, extends: :Child) do
        desc "say yes to mamá"
      end
      it("it's almost like class-based inheritance!!!") do
        base # hacks
        send(:SubChild1).summary.should eql(['sub-child1<-->WHOOTENANY'])
        send(:SubChild2).summary.should eql(['sub-child2<-->SAY YES TO MAMÁ'])
      end
    end
  end
end
