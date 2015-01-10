module Skylab::Callback

    class Event

      class Unwrappers__::Exception

        Callback_::Actor.call self, :properties,
          :event

        def execute
          resolve_exception_class
          resolve_message_string
          @exception_class.new @message_s
        end

      private

        def resolve_exception_class
          @exception_class = if @event.has_tag :error_category
            exception_class_via_error_catgory @event.error_category
          else
            ::RuntimeError
          end ; nil
        end

        def exception_class_via_error_catgory i
          _name = Callback_::Name.via_variegated_symbol i
          ::Object.const_get _name.as_camelcase_const
        end

        def resolve_message_string
          resolve_message_lines
          @message_s = Callback_.lib_.basic::String.
            paragraph_string_via_message_lines @message_s_a ; nil
        end

        def resolve_message_lines
          @event.render_all_lines_into_under @message_s_a=[], expression_agent
          nil
        end

        def expression_agent
          Callback_.lib_.brazen::API.expression_agent_instance  # hard-coded "black and white" for now
        end
      end
    end
end
