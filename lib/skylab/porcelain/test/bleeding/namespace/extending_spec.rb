require_relative '../test-support'

module ::Skylab::Porcelain::Bleeding::TestSupport
  describe "As for extending your namespace module with #{Bleeding::NamespaceModuleMethods}" do
    extend ModuleMethods ; include InstanceMethods
    base_module!
    with_namespace 'berse-nermsperce'
    with_action 'mer-nermsperce'
    klass :BerseNermsperce__MerNermsperce__MerErkshern do
      def invoke x ; "err-kerr-->#{x}<--" end
    end
    before(:all) do
      self.BerseNermsperce__MerNermsperce__MerErkshern # kick
    end
    def works # a common test below
      subject.fetch('mer-erk').bound_invocation_method.receiver.invoke('fluk').should eql("err-kerr-->fluk<--")
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
