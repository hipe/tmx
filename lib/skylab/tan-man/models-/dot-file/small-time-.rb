module Skylab::TanMan

  module Models_::DotFile

    module Small_Time_

      Actors = ::Module.new

      class Actors::Build_Document_Controller

        class Via_action < self

          Actor_.call self, :properties,
            :action

          def execute
            @kernel, @on_event_selectively = @action.controller_nucleus.to_a
            receive_input_arguments @action.input_arguments and super
          end

          def _produce_trio_box_proxy
            @action.to_trio_box_proxy
          end

          def _output_trio_array
            @action.output_arguments
          end
        end

        class Via_trio_box < self

          # some concerns (like hear-maps) don't have an action, but have
          # arguments and want a document controller.

          Actor_.call self, :properties,
            :trio_box, :kernel

          def execute

            in_a, @out_a = TanMan_::Model_::Document_Entity::Partition_IO_Args.new(
              @trio_box.to_value_stream,
              & @on_event_selectively ).partition_and_sort

            in_a and begin
              @in_arg_a = in_a
              dc = super
              dc and begin
                dc.caddied_output_args = @out_a
                dc
              end
            end
          end

          def _produce_trio_box_proxy
            @trio_box
          end

          def _output_trio_array
            @out_a
          end
        end

        def receive_input_arguments a
          if a and a.length.nonzero?
            @in_arg_a = a
            ACHIEVED_
          else
            when_no_IO :input
          end
        end

        def when_no_IO i
          maybe_send_event :error, :cannot_resolve_IO do
            build_not_OK_event_with :cannot_resolve_IO, :direction, i
          end
          UNABLE_
        end

        def execute
          ok = via_input_resolve_graph_sexp
          ok and via_graph_sexp_produce_document_controller
        end

        def via_input_resolve_graph_sexp
          arg = @in_arg_a.fetch 0
          sym = arg.name_symbol
          instance_variable_set :"@#{ sym }", arg.value_x
          send :"via_#{ sym }_resolve_graph_sexp"
        end

        def via_workspace_path_resolve_graph_sexp

          ok = __resolve_workspace_via_trio_box _produce_trio_box_proxy
          ok &&= __via_workspace_resolve_document
          ok &&= __via_document_resolve_graph_path
          ok &&= __via_graph_path_and_workspace_resolve_graph_sexp

        end

        def __resolve_workspace_via_trio_box bx

          @ws = @kernel.silo( :workspace ).workspace_via_trio_box bx,
            & @on_event_selectively

          @ws && ACHIEVED_
        end

        def __via_workspace_resolve_document

          ok = @ws.resolve_document_( & @on_event_selectively )
          if ok
            @doc = @ws.document_
          end
          ok
        end

        def __via_document_resolve_graph_path

          @graph_path = @doc.property_value_via_symbol GRPH___ do | i, i_, & ev_p |

            if :property_not_found == i_

              @on_event_selectively.call i, i_ do

                ev_p[].new_inline_with(
                  :invite_to_action, [ :graph, :use ],
                  :ok, false )  # client's won't look for invite otherwise..
              end

              UNABLE_
            else
              @on_event_selectively[ i, i_, & ev_p ]
            end
          end

          @graph_path && ACHIEVED_
        end

        GRPH___ = :graph

        def __via_graph_path_and_workspace_resolve_graph_sexp

          path = @graph_path ;  _surrounding_path = @ws.asset_directory_

          if path.length.nonzero? && ::File::SEPARATOR != path[ 0 ]
            path = ::File.expand_path path, _surrounding_path
          end

          @input_path = path

          ok = via_input_path_resolve_graph_sexp

          a = _output_trio_array

          if ok && a && :workspace_path == a.first.name_symbol

            # it's not very useful to have the workspace path as the output arg

            a[ 0 ] = Callback_::Pair[ path, :output_path ]  # structure violation

          end

          ok
        end

        def via_input_path_resolve_graph_sexp
          @graph_sexp = DotFile_.produce_parse_tree_via @on_event_selectively do | o |
            o.generated_grammar_dir_path _GGD_path
            o.input_path @input_path
          end
          @graph_sexp && ACHIEVED_
        end

        def via_input_string_resolve_graph_sexp
          @graph_sexp = DotFile_.produce_parse_tree_via @on_event_selectively do | o |
            o.generated_grammar_dir_path _GGD_path
            o.input_string @input_string
          end
          @graph_sexp && ACHIEVED_
        end

        def _GGD_path
          @kernel.call :paths, :path, :generated_grammar_dir, :verb, :retrieve
        end

        def via_graph_sexp_produce_document_controller
          DotFile_::Controller__.new @graph_sexp, @in_arg_a.fetch( 0 ), @kernel, & @on_event_selectively
        end
      end
    end
  end
end
