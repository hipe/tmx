module Skylab::TanMan

  module Models_::DotFile

    if false

      # (NOTE - when rekindled, this guy should break out into own file #todo)

    class Magnetics_::PersistDotFile_via_ByteDownstreamReference_and_GraphSexp

      Attributes_actor_.call( self,
        is_dry: nil,
      )

      def initialize id, gsp, x_a, & oes_p

        @byte_downstream_reference = id
        @graph_sexp = gsp
        @is_dry = false
        @listener = oes_p

        if x_a.length.nonzero?
          _kp = process_iambic_fully x_a
          _kp or self._FAILED
        end
      end

      def execute

        y = if @is_dry
          Brazen_::Collection::ByteDownstreamReference.the_dry_identifier.to_minimal_yielder
        else
          @byte_downstream_reference.to_minimal_yielder
        end

        bytes = @graph_sexp.unparse_into y

        if y.respond_to? :close
          y.close
        end

        @listener.call :info, :wrote_resource do
          __build_event bytes
        end

        ACHIEVED_  # not bytes, it's confusing to the API
      end

      def __build_event bytes

        Common_::Event.inline_OK_with :wrote_resource,

            :byte_downstream_reference, @byte_downstream_reference,
            :bytes, bytes,
            :is_dry, @is_dry,
            :is_completion, true do  | y, o |

          id = o.byte_downstream_reference

          _s = id.description_under self

          s = id.EN_preposition_lexeme
          if s
            _to = " #{ s }"
          end

          y << "wrote#{ _to  } #{ _s } #{

            }(#{ o.bytes }#{ ' dry' if o.is_dry } bytes)"

        end
      end
    end
    end  # if false

    class DocumentController_via_Request < Common_::MagneticBySimpleModel

      def initialize
        @__mutex_for_solve_BUR = nil
        super
      end

      def qualified_knownness_box= bx
        _solve_BUR_via :__solve_BUR_via_box
        @__box = bx
      end

      def _solve_BUR_via m
        remove_instance_variable :@__mutex_for_solve_BUR
        @__solve_BUR = m
      end

      attr_writer(
        :invocation,
        :listener,
      )

      # --

      def execute

        ok = true
        ok &&= __resolve_BUR
        ok &&= __resolve_generated_grammar_dir_path
        ok &&= __via_BUR_resolve_graph_sexp
        ok && __via_graph_sexp_produce_doc_controller
      end

      def __via_graph_sexp_produce_doc_controller

        Here_::DocumentController___.define do |o|
          o.byte_upstream_reference = @_BUR
          o.graph_sexp = @graph_sexp
          o.invocation = @invocation
          o.listener = @listener
        end
      end

      def __via_BUR_resolve_graph_sexp

        _path = remove_instance_variable :@__generated_grammar_dir_path

        _gs = Here_::ParseTree_via_ByteUpstreamReference.via(

          :byte_upstream_reference, @_BUR,
          :generated_grammar_dir_path, _path,

          & @listener )

        _store :@graph_sexp, _gs
      end

      def __resolve_generated_grammar_dir_path

        _ = @invocation.generated_grammar_dir__
        _store :@__generated_grammar_dir_path, _
      end

      def __resolve_BUR
        _ = send remove_instance_variable :@__solve_BUR
        _store :@_BUR, _
      end

      def __solve_BUR_via_box

        bx = remove_instance_variable :@__box

        Home_::DocumentMagnetics_::ByteStreamReference_via_Request.call_by do |o|

          o.qualified_knownness_box = bx
          o.will_solve_for :input
          o.listener = @listener
        end
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

    end
  end
end
# #history-A: rewritten from "smalls"-style magnetics file to house only 1 magnetic
