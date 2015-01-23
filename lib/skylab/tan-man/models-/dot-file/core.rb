module Skylab::TanMan

  module Models_::DotFile  # cannot be a model subclass because treetop

    class << self

      def produce_document_via_parse & p
        DotFile_::Actors__::Produce_document_via_parse[ p ]
      end

      # ~

      def to_upper_unbound_action_stream
      end

      def is_silo
        true
      end

      # ~ the stack (we have to write them explicitly because treetop)

      def collection_controller_class
        Collection_Controller__
      end

      def silo_controller_class
        Silo_Controller__
      end

      def silo_class
        Silo__
      end

      # ~ support

      def node_identifier
        @nid ||= Brazen_::Node_Identifier_.via_symbol :dot_file
      end

      def preconditions
        # for *now* the buck stops here, maybe one day 'workspace'
      end

      def persist_to
        # same as above
      end
    end

    Actions = ::Module.new

    Collection_Controller__ = :_NONE_

    class Silo_Controller__ < Model_lib_[].silo_controller_class

      def provide_collection_controller_precon _id, graph
        DotFile_::Actors__::Build_Document_Controller::Via_action[ graph.action ]
      end
    end

    class Silo__ < Model_lib_[].silo_class

      def model_class
        DotFile_
      end

      def document_controller_via_argument_box bx, & oes_p
        DotFile_::Actors__::Build_Document_Controller::Via_argument_box[ bx, @kernel, & oes_p ]
      end
    end

    DotFile_ = self

  end
end
