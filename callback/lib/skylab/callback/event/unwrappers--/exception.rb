module Skylab::Callback

    class Event

      class Unwrappers__::Exception

        Home_::Actor.call self, :properties,
          :event

        def execute
          resolve_exception_class
          resolve_message_string
          @exception_class.new @message_s
        end

      private

        def resolve_exception_class
          @exception_class = if @event.has_member :error_category
            ___exception_class_via_error_category @event.error_category
          else
            ::RuntimeError
          end ; nil
        end

        def ___exception_class_via_error_category sym

          first_guess_sym = Home_::Name.via_variegated_symbol( sym ).
            as_camelcase_const

          if ::Object.const_defined? first_guess_sym

            ::Object.const_get first_guess_sym
          else
            _s_a = sym.id2name.split UNDERSCORE_  # e.g `errno_enoent`

            Home_::Autoloader.const_reduce _s_a, ::Object
          end
        end

        def resolve_message_string
          resolve_message_lines
          @message_s = Home_.lib_.basic::String.
            paragraph_string_via_message_lines @message_s_a ; nil
        end

        def resolve_message_lines
          @event.express_into_under @message_s_a=[], expression_agent
          nil
        end

        def expression_agent
          Home_.lib_.brazen::API.expression_agent_instance  # hard-coded "black and white" for now
        end
      end
    end
end
