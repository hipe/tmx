module Skylab::TanMan

  module Models_::DotFile  # cannot be a model subclass because of the
    # combinaton of facts that a) treetop allows grammar to be nested within
    # ruby modules but not classes and b) we want to nest our treetop
    # grammars under the relevant model node (this one).

    DEFAULT_EXTENSION = '.dot'.freeze

    if false
    class << self

      def produce_parse_tree_with * x_a, & oes_p

        Here_::ParseTree_via_ByteUpstreamReference.call_via_iambic x_a do | * i_a, & ev_p |

          # errors like file not found etc (that stem from path math errors)
          # have causes that are so hard to track down we throw them so that
          # the call stack is presented immediately rather than from hunting

          if :error == i_a.first && :stat_error == i_a[ 1 ]
            raise ev_p[].exception
          else
            oes_p[ * i_a, & ev_p ]
          end
        end
      end

      # ~ support

      def node_identifier
        @___nid ||= Brazen_::Concerns_::Identifier.via_symbol :dot_file  # :+#encapsulation-violation
      end

      def preconditions
        # for *now* the buck stops here, maybe one day 'workspace'
      end

      def persist_to
        # same as above
      end
    end

    Actions = ::Module.new

    class Silo_Daemon < Silo_daemon_base_class_[]

      def precondition_for action, id, box, & oes_p

        o = Here_::Small_Time_::Sessions::Build_Document_Controller.new
        o.receive_document_action action
        o.produce_document_controller
      end

      def document_controller_via_byte_upstream_reference id, & oes_p

        o = Here_::Small_Time_::Sessions::Build_Document_Controller.new( @kernel, & oes_p )
        o.receive_byte_upstream_reference id
        o.produce_document_controller
      end

      def document_controller_via_qualified_knownness_box bx, & oes_p

        o = Here_::Small_Time_::Sessions::Build_Document_Controller.new( @kernel, & oes_p )
        o.receive_qualified_knownness_box bx
        o.produce_document_controller
      end
    end

    end
    Here_ = self
  end
end
