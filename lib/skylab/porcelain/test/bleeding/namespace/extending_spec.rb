require_relative '../test-support'

module ::Skylab::Porcelain::TestSupport::Bleeding # #po-008
  describe "As for extending your namespace module with #{Bleeding::NamespaceModuleMethods}" do
    extend Bleeding_TestSupport

    incrementing_anchor_module!
    with_namespace 'berse-nermsperce'
    with_action 'mer-nermsperce'
    klass :BerseNermsperce__MerNermsperce__MerErkshern do
      def process x ; "err-kerr-->#{x}<--" end
    end
    before(:all) do
      self.BerseNermsperce__MerNermsperce__MerErkshern # #kick
    end
    def works # a common test below
      subject.fetch('mer-erk').bound_invocation_method.receiver.process('fluk').should eql("err-kerr-->fluk<--")
    end
    context "a plain old module with a plain old action in it" do
      modul :BerseNermsperce__MerNermsperce
      it('works') { works }
    end
    context "A module that extends NamespaceModuleMethods" do
      modul :BerseNermsperce__MerNermsperce do
        extend Bleeding::NamespaceModuleMethods
      end
      it('works') { works }
    end
    context "A module that extends a module that includes NamespaceModuleMethods" do
      modul(:FooMod) { extend Bleeding::NamespaceoduleMethods }
      modul :BerseNermsperce__MerNermsperce do
        module self::FooMod
          include Bleeding::NamespaceModuleMethods
        end
        extend self::FooMod
      end
      it('works') { works }
    end
  end
end
