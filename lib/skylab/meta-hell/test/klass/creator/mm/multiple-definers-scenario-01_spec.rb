require_relative 'test-support'

module ::Skylab::MetaHell::TestSupport::Klass::Creator::ModuleMethods

  module MultipleDefiners_Scenario_One

    o = { }

    o[:once] = -> do

      module Dingle
        extend MetaHell::Klass::Creator
        extend MetaHell::Let
        klass :Alpha do
          $stderr.puts "ONCE: #{self.object_id}"
          # fail('where')
          def wrong ; end
        end
        klass :Bravo, extends: :Alpha do
        end
      end

      module Fingle
        extend MetaHell::Klass::Creator
        extend MetaHell::Let
        klass :Alpha do
          $stderr.puts "TWICE: #{self.object_id}"
          def right ; end
        end
      end

      class Weiner
        extend MetaHell::Let
        include MetaHell::Klass::Creator::InstanceMethods
        include Dingle
        include Fingle
        let( :meta_hell_anchor_module ) { ::Module.new }
      end

      FUN[:once] = -> { $stderr.puts "NOPE: scenario one is done" }

    end

    FUN = MetaHell::Struct[ o ] # make a struct object out of the hash

    describe "#{MetaHell::Klass::Creator::ModuleMethods} Multiple Definers #{
      } Scenario One -- our graph accross a real graph" do

      before( :all ) { FUN.once[] }

      it "lets you override an entire node (definition) in a parent graph" do
        w = Weiner.new
        w.Bravo.ancestors[1].to_s.should eql('Alpha')
        w.Bravo.ancestors[1].instance_methods(false).should eql([:right])
      end
    end
  end
end
