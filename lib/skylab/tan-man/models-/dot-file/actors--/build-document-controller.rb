module Skylab::TanMan

  module Models_::DotFile

    module Actors__

      class Build_Document_Controller

        class Via_action < self

          Callback_::Actor[ self, :properties,
            :action ]

          def execute
            @event_receiver, @kernel = @action.controller_nucleus.to_a

            o = @action.argument_box ; @action = nil

            @input_string = o[ :input_string ]
            @input_pathname = o[ :input_pathname ]
            @output_string = o[ :output_string ]
            @output_pathname = o[ :output_pathname ]

            super
          end
        end

        Callback_::Actor[ self, :properties,
          :input_string, :output_string,
          :input_pathname, :output_pathname,
          :parsing_event_subscription,
          :event_receiver, :kernel ]

        def initialize
          @input_string = @output_string = @output_pathname = nil
          @parsing_event_subscription = nil
          super
        end

        def execute
          ok = via_input_resolve_graph_sexp
          ok and via_graph_sexp_produce_document_controller
        end

        def via_input_resolve_graph_sexp
          @subscribe = build_subscribe_proc
          if @input_string
            via_input_string_resolve_graph_sexp
          else
            via_input_pathname_resolve_graph_sexp
          end
        end

        def build_subscribe_proc
          -> o do
            o.subscribe_all
            o.use_subscription_channel_name_in_receiver_method_name
            o.delegate_to @event_receiver
            if @parsing_event_subscription
              @parsing_event_subscription[ o ]
            end ; nil
          end
        end

        def via_input_pathname_resolve_graph_sexp
          @graph_sexp = DotFile_.produce_document_via_parse do |parse|
            parse.via_input_pathname @input_pathname
            parse.subscribe( & @subscribe )
          end
          @graph_sexp && ACHEIVED_
        end

        def via_input_string_resolve_graph_sexp
          @graph_sexp = DotFile_.produce_document_via_parse do |parse|
            parse.via_input_string @input_string
            parse.subscribe( & @subscribe )
          end
          @graph_sexp && ACHEIVED_
        end

        def via_graph_sexp_produce_document_controller
          DotFile_::Controller__.new @graph_sexp, @event_receiver, @kernel
        end
      end
    end
  end
end
