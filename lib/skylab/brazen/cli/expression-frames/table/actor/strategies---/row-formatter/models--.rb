module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    Strategies___::Row_Formatter::Models__ = ::Module.new

    class Strategies___::Row_Formatter::Models__::Field

      class Builder

        # (this is the would-be "assembler" of dependency injection)

        def initialize parent_x

          disp = Brazen_.lib_.plugin::Pub_Sub::Dispatcher.new self, EMITS__

          disp.load_plugins_in_module Table_Impl_::Field_Strategies_

          disp.receive_plugin Core_Properties___.new_via_resources self

          @_disp = disp

          @_parent_x = parent_x
        end

        def new_via_polymorphic_stream_passively st

          if st.no_unparsed_exists

            Field_.new

          elsif st.current_token.respond_to? :ascii_only?

            # special terse form: IFF the first term after the `field`
            # keyword is a string, treat it as a label argument AND finish
            # the field (i.e. don't parse anything else after towards this
            # field). (makes definitions for commonest fields more readable.)

            Field_.new do | f |
              f.label = st.gets_one
            end

          else

            __one_field_via_nonempty_upstream st
          end
        end

        def __one_field_via_nonempty_upstream st

          o = Brazen_.lib_.plugin::Sessions::Shared_Parse.new
          o.be_passive = true
          o.dispatcher = @_disp
          o.upstream = st
          Field_.new do | f |
            @_current_field = f
            o.execute or raise ::Argumentative_strategy_class_
            remove_instance_variable :@_current_field
          end
        end

        def current_field
          @_current_field
        end

        # ~ etc API

        def touch_role k, & x_p
          @_parent_x.touch_role k, & x_p
        end
      end

      class Core_Properties___ < Argumentative_strategy_class_[]

        PROPERTIES = [
          :argument_arity, :one, :property, :celifier_builder,
          :argument_arity, :one, :property, :label,
          :argument_arity, :zero, :property, :left,
          :argument_arity, :zero, :property, :right,
        ]

        def receive__celifier_builder__argument x
          @resources.current_field.celifier_builder = x
          KEEP_PARSING_
        end

        def receive__label__argument x
          @resources.current_field.label = x
          KEEP_PARSING_
        end

        def receive__left__

          # (although "is left" is the default, we may be overwriting a
          # value that was previously expressed explicitly by the user)

          @resources.current_field.is_right = false
          KEEP_PARSING_
        end

        def receive__right__
          @resources.current_field.is_right = true
          KEEP_PARSING_
        end
      end

      Field_ = self

      class Field_  # self as class

        attr_accessor(
          :celifier_builder,
          :is_right,
          :label,
        )

        def initialize
          @_component_box = nil
          yield self
          freeze
          if @_component_box
            @_component_box.freeze
          end
        end

        def mutate_client
          NIL_
        end

        # ~ "components"

        def [] sym
          if @_component_box
            @_component_box[ sym ]
          end
        end

        def add_component sym, x
          @_component_box ||= Callback_::Box.new
          @_component_box.add sym, x
          NIL_
        end
      end
    end
  end
end
