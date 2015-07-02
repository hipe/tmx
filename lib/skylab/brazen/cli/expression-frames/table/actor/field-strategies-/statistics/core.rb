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

        # if you are tempted to simplify this out, read [#096.I]: because
        # fields are re-used and inheritable, we must do this all at once,
        # discretely.

        def initialize parent
          @parent = parent
        end

        # (dup when covered)

        def roles
        end

        def subscriptions
          [
            :receive_complete_field_list,
            :before_first_row,
          ]
        end

        def receive_complete_field_list fld_a

          @_gather_d_a = nil

          fld_a.each_with_index do | fld, d |

            do_gather = fld[ :do_gather_stats ]
            p = fld[ :formula_proc ]

            # the two used to be mutually excluse ..

            if do_gather
              ( @_gather_d_a ||= [] ).push d
              __process_gatherer_field d, fld
            end

            if p
              @parent.set_formula d, & p
            end
          end

          NIL_
        end

        def __process_gatherer_field d, fld

          mdl = Stats_::Models__::Seer.new

          @parent.add_column_element mdl.survey, :stats, d

          @parent.add_column_data_observer mdl, d

          NIL_
        end

        def before_first_row

          # every field that gathered statistics will get its stringifiers
          # rewritten to take into account the type profile for the column
          # unless someone else set the stringifier explicitly already

          d_a = @_gather_d_a
          if d_a
            d_a.each do | d |
              @parent.touch_stringifier d do
                _col = @parent.column_at d
                _col[ :stats ].appropriate_stringifier
              end
            end
          end
          KEEP_PARSING_
        end
      end

      Stats_ = self
    end
  end
end
