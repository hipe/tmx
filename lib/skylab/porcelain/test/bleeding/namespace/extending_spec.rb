require_relative '../test-support'

module Skylab::Porcelain::TestSupport::Bleeding # #po-008


  describe "[po][bl] namespace exending" do

    extend Bleeding_TestSupport

    incrementing_anchor_module!

    with_namespace 'berse-nermsperce'
    with_action 'mer-nermsperce'

    klass :BerseNermsperce__MerNermsperce__MerErkshern do
      def process x ; "err-kerr-->#{x}<--" end
    end

    before :each do
      self.BerseNermsperce__MerNermsperce__MerErkshern # #kick
    end

    def works # a common test below
      subject.fetch('mer-erk').bound_invocation_method.receiver.process('fluk').should eql("err-kerr-->fluk<--")
    end

    context "a plain old module with a plain old action in it" do

      modul :BerseNermsperce__MerNermsperce

      it 'works' do
        works
      end
    end

    context "A module that extends NamespaceModuleMethods" do

      modul :BerseNermsperce__MerNermsperce do
        extend Bleeding::NamespaceModuleMethods
      end

      it 'works' do
        works
      end
    end

    context "A module that extends a module that includes NamespaceModuleMethods" do

      modul :FooMod do
        extend Bleeding::NamespaceModuleMethods
      end

      modul :BerseNermsperce__MerNermsperce do |ctx|
        extend ctx.FooMod
      end

      it 'works' do
        works
      end
    end
  end
end
