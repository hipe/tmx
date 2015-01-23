module Skylab::TanMan

  module Models_::DotFile

    module Actors__

      class Build_Document_Controller

        class Via_action < self

          Actor_.call self, :properties,
            :action

          def execute
            @kernel, @on_event_selectively = @action.controller_nucleus.to_a
            ok = set_input_argument( * @action.input_arguments )
            ok and super
          end
        end

        class Via_argument_box < self

          # some concerns (like hear-maps) don't have an action, but have
          # arguments and want a document controller.

          Actor_.call self, :properties,
            :bx, :kernel

          def execute

            o = TanMan_::Model_::Document_Entity

            @input_arg, output_args = o::IO_Argument_Partition_Session.new(
              @bx.method( :to_pair_stream ),
              o.IO_properties_shell,
              & @on_event_selectively ).to_one_input_and_many_output_args

            @input_arg and begin
              dc = super
              dc and begin
                dc.caddied_output_args = output_args
                dc
              end
            end
          end
        end

        Callback_::Actor.call self, :properties,
          :input_arg,
          :parsing_event_subscription,
          :kernel

        def initialize
          @parsing_event_subscription = nil
          super
        end

        def set_input_argument x
          if x
            @input_arg = x ; ACHIEVED_
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
          @subscribe = build_subscribe_proc
          instance_variable_set :"@#{ @input_arg.name_symbol }", @input_arg.value_x
          send :"via_#{ @input_arg.name_symbol }_resolve_graph_sexp"
        end

        def build_subscribe_proc
          -> o do
            o.subscribe_all
            o.use_subscription_channel_name_in_receiver_method_name
            o.delegate_to_selectively @on_event_selectively
            if @parsing_event_subscription
              @parsing_event_subscription[ o ]
            end ; nil
          end
        end

        def via_workspace_path_resolve_graph_sexp

          ws = @kernel.silo( :workspace ).
            build_silo_controller( & @on_event_selectively ).
              workspace_via_rising_action @action

          ws and __resolve_graph_sexp_via_workspace ws
        end

        def __resolve_graph_sexp_via_workspace ws

          x = ws.datastore.property_value_via_symbol GRPH___ do | i, i_, & ev_p |

            if :property_not_found == i_

              @on_event_selectively.call i, i_ do

                ev = ev_p[]
                i_a = ev.to_iambic
                i_a.push :invite_to_action, [ :graph, :use ]
                Callback_::Event.inline_via_iambic_and_message_proc i_a, ev.message_proc  # while #open [#cb-025]

              end

              UNABLE_
            else
              @on_event_selectively[ i, i_, & ev_p ]
            end
          end
          x and __resolve_graph_sexp_via_graph_path x, ws.to_path
        end

        GRPH___ = :graph

        def __resolve_graph_sexp_via_graph_path path, derelativizer
          if path.length.nonzero? && ::File::SEPARATOR != path[ 0 ]
            path = ::File.join ::File.dirname( derelativizer ), path
          end
          @input_path = path
          ok = via_input_path_resolve_graph_sexp
          if ok && :workspace_path == @action.output_arguments.first.name_symbol

            # it's not very useful to have the workspace path as the output arg

            @action.output_arguments[ 0 ] = Callback_.pair.new( path, :output_path )

          end
          ok
        end

        def via_input_path_resolve_graph_sexp
          @graph_sexp = DotFile_.produce_document_via_parse do |parse|
            parse.generated_grammar_dir_path _GGD_path
            parse.via_input_path @input_path
            parse.subscribe( & @subscribe )
          end
          @graph_sexp && ACHIEVED_
        end

        def via_input_string_resolve_graph_sexp
          @graph_sexp = DotFile_.produce_document_via_parse do |parse|
            parse.generated_grammar_dir_path _GGD_path
            parse.via_input_string @input_string
            parse.subscribe( & @subscribe )
          end
          @graph_sexp && ACHIEVED_
        end

        def _GGD_path
          @kernel.call :paths, :generated_grammar_dir, :retrieve
        end

        def via_graph_sexp_produce_document_controller
          DotFile_::Controller__.new @graph_sexp, @input_arg, @kernel, & @on_event_selectively
        end
      end
    end
  end
end
