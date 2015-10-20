module Skylab::TanMan

  module Models_::DotFile

    Small_Time_ = ::Module.new

    Small_Time_::Actors = ::Module.new

    Small_Time_::Sessions = ::Module.new

    class Small_Time_::Actors::Persist

      Callback_::Actor.methodic self, :properties, :is_dry

      def initialize id, gsp, x_a, & oes_p
        @byte_downstream_identifier = id
        @graph_sexp = gsp
        @is_dry = false
        @on_event_selectively = oes_p
        if x_a.length.nonzero?
          process_polymorphic_stream_fully polymorphic_stream_via_iambic x_a
        end
      end

      def execute

        y = if @is_dry
          Brazen_::Collection::Byte_Downstream_Identifier.the_dry_identifier.to_minimal_yielder
        else
          @byte_downstream_identifier.to_minimal_yielder
        end

        bytes = @graph_sexp.unparse_into y

        if y.respond_to? :close
          y.close
        end

        @on_event_selectively.call :info, :wrote_resource do
          __build_event bytes
        end

        ACHIEVED_  # not bytes, it's confusing to the API
      end

      def __build_event bytes

        Callback_::Event.inline_OK_with :wrote_resource,

            :byte_downstream_identifier, @byte_downstream_identifier,
            :bytes, bytes,
            :is_dry, @is_dry,
            :is_completion, true do  | y, o |

          id = o.byte_downstream_identifier

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

    class Small_Time_::Sessions::Build_Document_Controller

      def initialize kr=nil, & oes_p
        @kernel = kr
        @on_event_selectively = oes_p
      end

      def receive_document_action action
        @kernel, @on_event_selectively = action.controller_nucleus.to_a
        receive_byte_upstream_identifier action.document_entity_byte_upstream_identifier
        produce_document_controller
      end

      def receive_qualified_knownness_box bx

        o = Home_::Model_::Document_Entity::
          Byte_Stream_Identifier_Resolver.new(
            @kernel, & @on_event_selectively )

        o.against_qualified_knownness_box bx

        @_BUID = o.solve_for :input

        nil
      end

      def receive_byte_upstream_identifier id
        @_BUID = id ; nil
      end

      def produce_document_controller
        @_BUID and begin
          ok = __via_BUID_resolve_graph_sexp
          ok && __via_graph_sexp_produce_doc_controller
        end
      end

      def __via_BUID_resolve_graph_sexp

        @graph_sexp = DotFile_.produce_parse_tree_with(

          :byte_upstream_identifier, @_BUID,
          :generated_grammar_dir_path, __GGD_path,

          & @on_event_selectively )

        @graph_sexp && ACHIEVED_
      end

      def __GGD_path
        @kernel.call :paths, :path, :generated_grammar_dir, :verb, :retrieve
      end

      def __via_graph_sexp_produce_doc_controller

        DotFile_::Controller__.new @graph_sexp, @_BUID, @kernel, & @on_event_selectively
      end
    end
  end
end
