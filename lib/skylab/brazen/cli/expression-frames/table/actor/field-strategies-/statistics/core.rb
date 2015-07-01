module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    class Field_Strategies_::Statistics

      ARGUMENTS = [
        :argument_arity, :zero, :property, :gather_statistics,
        :argument_arity, :one, :property, :formula,
      ]

      ROLES = nil

      Table_Impl_::Strategy_::Has_arguments[ self ]

      def initialize x
        @parent = x
      end

      def receive__gather_statistics__flag

        @parent.current_field.add_component :do_gather_stats, true

        @parent.field_parent.touch_dynamic_dependency Dynamic_Dependency

        KEEP_PARSING_
      end

      def receive__formula__argument p

        fld = @parent.current_field

        fld.add_component :formula_proc, p

        KEEP_PARSING_
      end

      class Dynamic_Dependency

        # if you are tempted to simplify this out, read [#096.I]. because
        # fields are re-used and inheritable, we must do this all at once,
        # discretely.

        def initialize parent
          @parent = parent
        end

        # (dup when covered)

        def roles
        end

        def subscriptions
          [ :receive_complete_field_list ]
        end

        def receive_complete_field_list fld_a

          fld_a.each_with_index do | fld, d |

            do_gather = fld[ :do_gather_stats ]
            p = fld[ :formula_proc ]

            # the two used to be mutually excluse ..

            if do_gather
              __process_gatherer_field d, fld
            end

            if p
              @parent.set_formula d, & p
            end
          end

          NIL_
        end

        def __process_gatherer_field d, fld

          mdl = Statistics_Model___.new

          @parent.add_column_element mdl, :stats, d

          @parent.add_user_datapoint_observer d do | x |
            mdl.see x
            NIL_
          end
          NIL_
        end
      end

      class Statistics_Model___

        def numeric_max
          @numeric_max
        end

        def initialize
          @numeric_max = 0
        end

        def see x
          if ::Numeric === x
            if @numeric_max < x
              @numeric_max = x
            end
          end
          NIL_
        end
      end
    end
  end
end
