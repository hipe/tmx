require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Class::Creator::ModuleMethods

  module MultipleDefiners_Scenario_One

    Once__ = Callback_.memoize do

      module Dingle
        extend MetaHell_::Class::Creator
        extend MetaHell_::Let
        klass :Alpha do
          def wrong ; end
        end
        klass :Bravo, extends: :Alpha do
        end
      end

      module Fingle
        extend MetaHell_::Class::Creator
        extend MetaHell_::Let
        klass :Alpha do
          def right ; end
        end
      end

      class Weiner
        extend MetaHell_::Let
        include MetaHell_::Class::Creator::InstanceMethods
        include Dingle
        include Fingle
        let( :meta_hell_anchor_module ) { ::Module.new }
      end

      :_did_
    end

    describe "[mh] Class::Creator::ModuleMethods Multiple Definers #{
      } Scenario One -- our graph accross a real graph" do

      before :all do
        Once__[]
      end

      it "lets you override an entire node (definition) in a parent graph" do
        w = Weiner.new
        w.Bravo.ancestors[1].to_s.should eql('Alpha')
        w.Bravo.ancestors[1].instance_methods(false).should eql([:right])
      end
    end
  end
end
