module Skylab::TanMan

  module Models_::DotFile

    module Actors__

      class Build_Document_Controller

        class Via_action < self

          Actor_[ self, :properties,
            :action ]

          def execute
            @event_receiver, @kernel = @action.controller_nucleus.to_a

            o = @action.argument_box

            @input_string = o[ :input_string ]
            @input_pathname = o[ :input_pathname ]
            @output_string = o[ :output_string ]
            @output_pathname = o[ :output_pathname ]

            if @input_string || @input_pathname
              @action = nil
              super
            else
              when_no_input
            end
          end

          def when_no_input
            a = @action.class.properties.at :input_string, :input_pathname
            _ev = build_not_OK_event_with :cannot_resolve_input, :prop_a, a do |y, o|
              _s_a = o.prop_a.map do |prop|
                par prop
              end
              y << "cannot resolve input - need #{ or_ _s_a }"
            end
            send_event _ev
          end
        end

        Callback_::Actor[ self, :properties,
          :input_string, :output_string,
          :input_pathname, :output_pathname,
          :parsing_event_subscription,
          :event_receiver, :kernel ]

        def initialize
          @input_string = @input_pathname = nil
          @output_string = @output_pathname = nil
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
          elsif @input_pathname
            via_input_pathname_resolve_graph_sexp
          else
            when_no_input
          end
        end

        def when_no_input
          _ev = build_not_OK_event_with :cannot_resolve_input do |y, o|
            y << "cannot resolve input - need  #{ par :input_string } or #{
             }#{ par :input_pathname }"
          end
          send_event _ev
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
