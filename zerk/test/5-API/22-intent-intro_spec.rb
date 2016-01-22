require_relative '../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] for interface - (1) intent: with an intent of..", wip: true do

    TS_[ self ]
    use :memoizer_methods

    context "`API`:" do

      it "it is a recognized intent" do
        _intent.should eql :API
      end

      it "it fits into a hardcoded taxonomy" do
        _taxonomy
      end

      def _qkn
        _shared_structure.fetch 0
      end
    end

    context "`UI`:" do

      it "[..] recognized" do
        _intent.should eql :UI
      end

      it "[..] taxonomy" do
        _taxonomy
      end

      def _qkn
        _shared_structure.fetch 1
      end
    end

    context "`interface`:" do

      it "[..] recognized" do
        _intent.should eql :interface
      end

      it "[..] taxonomy" do
        _taxonomy
      end

      def _qkn
        _shared_structure.fetch 2
      end
    end

    def _taxonomy

      _sym = _intent
      Home_::For_Interface::Is_interface_intent___[ _sym ] or fail
    end

    def _intent
      _qkn.association.intent
    end

    shared_subject :_shared_structure do

      _me = _my_model.new

      _st = Home_::Reflection::To_qualified_knownness_stream[ _me ]

      _st.to_a
    end

    dangerous_memoize :_my_model do

      class MC_1_Multi_Intent_Root

        def __resourcez__component_association
          yield :intent, :API
          :_ok_
        end

        def __floofie__component_association
          yield :intent, :UI
          :_ok_
        end

        def __both__component_association
          yield :intent, :interface
          :_ok_
        end

        self
      end
    end
  end
end
