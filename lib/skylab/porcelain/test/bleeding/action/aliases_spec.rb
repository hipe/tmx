require_relative '../test-support'

module Skylab::Porcelain::Bleeding::TestSupport
  describe "This is the deal with aliases with #{Bleeding::ActionModuleMethods} (NOT an inheritable attribute)" do
    extend ModuleMethods ; include InstanceMethods
    _hack = nil
    base_module!
    klass(:BaseAction) do
      extend Bleeding::ActionModuleMethods
    end
    klass(:Acts__ChildAction1, extends: :BaseAction)
    it "They can of course be accessed by action runtimes", f:true do
      send(:Acts__ChildAction1) # (we've got to kick it)
      act = Bleeding::NamespaceInferred.new(base_module::Acts).fetch('child-action1')
      act.aliases.should eql(['child-action1'])
    end
    it "But also they can be accessed of the action class itself" do
      send(:Acts__ChildAction1).aliases.should eql(['child-action1'])
    end
  end
end
