module Skylab::Brazen

  module Entity

    class Properties_Stack__

      class Define_process_method_  # rewrite of [#mh-060]

        Callback_::Actor.methodic self

        def initialize parse_context
          @is_complete = false
          @is_globbing = false
          @parse_context = parse_context
        end

        def execute
          keep_parsing = process_polymorphic_stream_passively @parse_context.upstream
          if @is_complete
            via_parse_context_flush
          elsif keep_parsing
            when_incomplete
          else
            keep_parsing
          end
        end

      private

        def globbing=
          @is_globbing = true
          KEEP_PARSING_
        end

        def processor=
          @is_complete = true
          @method_name = gets_one_polymorphic_value
          STOP_PARSING_
        end

        def when_incomplete
          self._RIDE_ME
          @parse_context.edit_session.maybe_receive_event :error, :incomplete
        end

        def via_parse_context_flush
          ent_class = @parse_context.edit_session.polymorphic_writer_method_writee_module
          is_globbing = @is_globbing
          method_name = @method_name
          ent_class.class_exec do
            @active_entity_edit_session.while_ignoring_method_added do
              if is_globbing
                define_method method_name do | * x_a |
                  _keep_parsing = process_polymorphic_stream_fully(
                    polymorphic_stream_via_iambic x_a )
                  _keep_parsing && normalize
                end
              else
                define_method method_name do | x_a |
                  _keep_parsing = process_polymorphic_stream_fully(
                    polymorphic_stream_via_iambic x_a )
                  _keep_parsing && normalize
                end
              end
            end
          end
          ACHIEVED_
        end
      end
    end
  end
end
