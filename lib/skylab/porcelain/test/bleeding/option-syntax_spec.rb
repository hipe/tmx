require_relative '../../core'
require_relative '../bleeding/test-support'

module Skylab::Porcelain::Bleeding::TestSupport
  describe Bleeding::OptionSyntax do
    extend Skylab::MetaHell::KlassCreator
    let(:base_module) { Module.new }

    klass :Alpha do
      extend Bleeding::ActionModuleMethods
    end

    klass :Bravo, extends: :Alpha do
    end

    klass :Charlie, extends: :Bravo do
    end

    def self.assert one, two
      context "option_syntax_class of #{one}" do
        let(:subject) { send(one).option_syntax_class }
        specify { should eql(two) }
      end
    end

    context "Alpha is an Action, Alpha begat Bravo begat Charlie" do
      assert :Alpha, Bleeding::OptionSyntax
      assert :Bravo, Bleeding::OptionSyntax
      assert :Charlie, Bleeding::OptionSyntax
    end

    context "If Alpha changes its option_syntax_class" do
      klass :Alpha do
        extend Bleeding::ActionModuleMethods
        option_syntax_class :shenanigans
      end
      assert :Alpha, :shenanigans
      assert :Bravo, :shenanigans
      assert :Charlie, :shenanigans
    end

    context "If Beta changes its option_syntax_class" do
      klass :Bravo do
        extend Bleeding::ActionModuleMethods
        option_syntax_class :foonanie
      end
      assert :Alpha, Bleeding::OptionSyntax
      assert :Bravo, :foonanie
      assert :Charlie, :foonanie
    end


    context "Charlie changes it, THEN Bravo changes it, then what does charlie have?" do
      it "is ok, charlie keeps its original fenangling" do
        self.Charlie.option_syntax_class :whatsit
        self.Charlie.option_syntax_class.should eql(:whatsit)
        self.Bravo.option_syntax_class :beavis
        self.Charlie.option_syntax_class.should eql(:whatsit)
        self.Bravo.option_syntax_class.should eql(:beavis)
      end
    end
  end
end

