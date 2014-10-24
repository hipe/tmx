module Skylab::TanMan

  module Models_::DotFile

    module Actors__

      class Build_Document_Controller

        class Via_action < self

          Actor_[ self, :properties,
            :action ]

          def execute
            @event_receiver, @kernel = @action.controller_nucleus.to_a
            ok = set_input_argument( * @action.input_arguments )
            ok and begin
              @action = nil
              super
            end
          end

      private

          def set_input_argument x
            if x
              @input_arg = x ; ACHIEVED_
            else
              when_no_IO :input
            end
          end

          def when_no_IO i
            _ev = build_not_OK_event_with :cannot_resolve_IO, :direction, i
            send_event _ev ; UNABLE_
          end
        end

        Callback_::Actor[ self, :properties,
          :input_arg,
          :parsing_event_subscription,
          :event_receiver, :kernel ]

        def initialize
          @parsing_event_subscription = nil
          super
        end

        def execute
          ok = via_input_resolve_graph_sexp
          ok and via_graph_sexp_produce_document_controller
        end

        def via_input_resolve_graph_sexp
          @subscribe = build_subscribe_proc
          instance_variable_set :"@#{ @input_arg.name_i }", @input_arg.value_x
          send :"via_#{ @input_arg.name_i }_resolve_graph_sexp"
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
            parse.generated_grammar_dir_path _GGD_path
            parse.via_input_pathname @input_pathname
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
          DotFile_::Controller__.new @graph_sexp, @input_arg, @event_receiver, @kernel
        end
      end
    end
  end
end
