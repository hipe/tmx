require_relative '../../test-support'

module Skylab::Basic::TestSupport

  module Cls_Crtr_MM___  # :+#throwaway-module for etc below

    # <-

  module MultipleDefiners_Scenario_One

    Once__ = Callback_.memoize do

      module Dingle

        Home_::Class::Creator[ self ]

        klass :Alpha do
          def wrong ; end
        end

        klass :Bravo, extends: :Alpha do
        end
      end

      module Fingle

        Home_::Class::Creator[ self ]

        klass :Alpha do
          def right ; end
        end
      end

      class Weiner

        include Home_::Class::Creator::InstanceMethods

        include Dingle

        include Fingle

        TestSupport_::Let[ self ]

        let( :meta_hell_anchor_module ) { ::Module.new }
      end

      :_did_
    end

    TS_.describe "[ba] class - creaator - module methods" do

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
# ->
  end
end
