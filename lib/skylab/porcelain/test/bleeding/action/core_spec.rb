require_relative 'test-support'

module Skylab::Porcelain::Bleeding::TestSupport
  describe "#{Bleeding::ActionModuleMethods}" do
    extend ModuleMethods
    include InstanceMethods
    _last = 0
    let(:base_module) { Skylab::Porcelain::Bleeding.const_set("XyzzyB#{_last += 1}", Module.new) }
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
  end
end
