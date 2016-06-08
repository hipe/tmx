module Skylab::Callback

  class Event
    # -
      class To_exception < Home_::Actor::Monadic

        def initialize event
          @event = event
        end

        def execute

          __init_exception_class
          __init_message_string

          if :name_error == @_error_category

            # (a little hard-coded help to make the generated event
            #  more appropriate. there is *no* way to automate this.)

            if @event.has_member :name
              _name = @event.name
            end

            @_exception_class.new @_message_s, _name
          else
            @_exception_class.new @_message_s
          end
        end

        def __init_exception_class

          if @event.has_member :error_category

            @_error_category = @event.error_category
            @_exception_class = Class_via_symbol[ @_error_category ]

          else
            @_error_category = nil
            @_exception_class = ::RuntimeError
          end
          NIL_
        end

        Class_via_symbol = -> sym, & els do  # [hu]

          first_guess_sym = Home_::Name.via_variegated_symbol( sym ).
            as_camelcase_const

          if ::Object.const_defined? first_guess_sym

            ::Object.const_get first_guess_sym
          else

            _s_a = sym.id2name.split UNDERSCORE_  # e.g `errno_enoent`

            Home_::Autoloader.const_reduce _s_a, ::Object, & els
          end
        end

        def __init_message_string

          _s_a = ___assemble_message_lines

          @_message_s =
            Home_.lib_.basic::String.paragraph_string_via_message_lines _s_a

          NIL_
        end

        def ___assemble_message_lines

          _expag = ___expression_agent
          @event.express_into_under [], _expag
        end

        def ___expression_agent
          Home_.lib_.brazen::API.expression_agent_instance  # hard-coded "black and white" for now
        end
      end
    # -
    To_Exception = To_exception
  end
end
