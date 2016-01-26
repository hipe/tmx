require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - intent intro", wip: true do  # was for 'for interface' of [aca]

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

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_23_Multi_Intent_Root ]
    end
  end
end
