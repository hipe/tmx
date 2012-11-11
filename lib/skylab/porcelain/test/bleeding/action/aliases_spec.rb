require_relative 'test-support'

module Skylab::Porcelain::TestSupport::Bleeding::Action
  describe "This is the deal with aliases with #{Bleeding::ActionModuleMethods
    } (NOT an inheritable attribute)" do

    extend Action_TestSupport

    incrementing_anchor_module!


    klass :BaseAction do
      extend Bleeding::ActionModuleMethods
    end

    klass :Acts__ChildAction1, extends: :BaseAction


    it "They can of course be accessed by action runtimes" do
      _Acts__ChildAction1 # #kick
      box = Bleeding::NamespaceInferred.new _Acts
      act = box.fetch 'child-action1'
      act.aliases.should eql(['child-action1'])
    end

    it "But also they can be accessed of the action class itself" do
      _Acts__ChildAction1.aliases.should eql(['child-action1'])
    end
  end
end
