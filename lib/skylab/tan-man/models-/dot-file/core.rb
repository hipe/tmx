module Skylab::TanMan

  module Models_::DotFile  # cannot be a model subclass because treetop

    class << self

      def produce_parse_tree_via oes_p
        _Sess = DotFile_::Sessions__::Produce_Parse_Tree
        bx = Callback_::Box.new
        yield _Sess::Shell.new bx
        _Sess.new bx do | * i_a, & ev_p |

          # errors like file not found etc (that stem from path math errors)
          # have causes that are so hard to track down we throw them so that
          # the call stack is presented immediately rather than from hunting

          if :error == i_a.first && :stat_error == i_a[ 1 ]
            raise ev_p[].exception
          else
            oes_p[ * i_a, & ev_p ]
          end
        end.produce_parse_tree
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

    class Silo_Controller__ < Brazen_.model.silo_controller_class

      def provide_collection_controller_precon _id, graph
        DotFile_::Actors__::Build_Document_Controller::Via_action[ graph.action ]
      end
    end

    class Silo_Daemon < Model_::Silo_Daemon

      def members
        [ :document_controller_via_trio_box, * super ]
      end

      def model_class
        DotFile_
      end

      def document_controller_via_trio_box bx, & oes_p
        DotFile_::Actors__::Build_Document_Controller::Via_trio_box[ bx, @kernel, & oes_p ]
      end
    end

    DotFile_ = self

  end
end
