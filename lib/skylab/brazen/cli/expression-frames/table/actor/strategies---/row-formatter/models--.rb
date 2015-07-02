module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    Strategies___::Row_Formatter::Models__ = ::Module.new

    class Strategies___::Row_Formatter::Models__::Field

      class Builder

        # (this is the would-be "assembler" of dependency injection)

        def initialize parent_x

          o = Home_.lib_.plugin::Dependencies.new self
          o.emits = [ :argument_bid_for ].freeze
          o.roles = EMPTY_A_
          o.index_dependencies_in_module Table_Impl_::Field_Strategies_
          o.index_dependency Core_Properties___

          @_deps = o
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

          Field_.new do | f |

            @_current_field = f

            _kp = @_deps.process_polymorphic_stream_passively st
            _kp or raise ::ArgumentError

            remove_instance_variable :@_current_field
          end
        end

        # ~ service API

        def current_field
          @_current_field
        end

        def field_parent
          @_parent_x
        end
      end

      class Core_Properties___

        ARGUMENTS = [
          :argument_arity, :one, :property, :stringifier,
          :argument_arity, :one, :property, :celifier_builder,
          :argument_arity, :one, :property, :label,
          :argument_arity, :zero, :property, :left,
          :argument_arity, :zero, :property, :right,
        ]

        ROLES = nil

        Table_Impl_::Strategy_::Has_arguments[ self ]

        def initialize x
          @parent = x
        end

        undef_method :dup  # needs impl

        def receive__celifier_builder__argument x
          @parent.current_field.celifier_builder = x
          KEEP_PARSING_
        end

        def receive__label__argument x
          @parent.current_field.label = x
          KEEP_PARSING_
        end

        def receive__left__flag

          # (although "is left" is the default, we may be overwriting a
          # value that was previously expressed explicitly by the user)

          @parent.current_field.is_right = false
          KEEP_PARSING_
        end

        def receive__stringifier__argument x
          @parent.current_field.receive_stringifier x
          KEEP_PARSING_
        end

        def receive__right__flag
          @parent.current_field.is_right = true
          KEEP_PARSING_
        end
      end

      Field_ = self

      class Field_  # self as class

        attr_reader(
          :stringifier,
          :stringifier_was_specified,
        )

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

        def receive_stringifier x
          @stringifier = x
          @stringifier_was_specified = true
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

    class Strategies___::Row_Formatter::Models__::Column

      # in contrast to a "field", a "column" is a function of the
      # particular user data for this one table (rendering)

      attr_accessor(
        :field,
      )

      def initialize
        yield self
        freeze
      end

      def receive_column_box bx
        @_bx = bx ; nil
      end

      def receive_column_proc p
        @_column_p = p ; nil
      end

      def [] sym
        @_bx[ sym ]
      end

      def column_at d
        @_column_p[ d ]
      end
    end

    Strategies___::Row_Formatter::Models__::ColumnMetrics =
      ::Struct.new :column_width, :column, :field

  end
end
