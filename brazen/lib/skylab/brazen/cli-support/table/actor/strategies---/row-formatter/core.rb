module Skylab::Brazen

  class CLI_Support::Table::Actor

    class Strategies___::Row_Formatter

      ARGUMENTS = [
        :argument_arity, :custom, :property, :field,
        :argument_arity, :one, :property, :target_width
      ]

      ROLES = nil

      Table_Impl_::Strategy_::Has_arguments[ self ]

      # ~

      def initialize x

        @_col_bx = nil
        @_deps = nil
        @_fld_a = nil
        @_do_calculation_pass = false
        @parent = x
        @_target_width = nil
      end

      def dup x

        otr = self.class.new x

        if @_deps
          deps = @_deps.dup otr
        end

        if @_fld_a
          fld_a = @_fld_a.dup  # assume fields themselves are immutable-ish
        end

        tw = @_target_width  # as-is

        otr.instance_exec do
          @_deps = deps
          @_fld_a = fld_a
          @_target_width = tw
        end

        otr
      end

      # ~ begin frontier

      def argument_bid_for tok

        my_bid = super
        if my_bid
          my_bid
        else
          @_deps || _init_deps
          g = @_deps.argument_bid_group_for tok
          if g
            @_deps.class::Argument::Bid.new( self, g.arity_symbol, g )
          end
        end
      end

      def receive_term term, bid

        g = bid.implementation_x
        if g

          # one or more of your depdendencies bid on the argument, ergo
          # make sure you are active so you get control of rendering

          _be_active

          @_deps.class::Argument::Dispatch_term[ g, term ]
        else
          super
        end
      end

      # ~ end

      def receive_stream_after__field__ st

        @__field_builder ||= Me_the_Strategy_::Models__::Field::Builder.new self

        fld = @__field_builder.new_via_polymorphic_stream_passively st

        ( @_fld_a ||= [] ).push fld

        _be_active

        KEEP_PARSING_
      end

      def receive__target_width__argument x
        @_target_width = x
        KEEP_PARSING_
      end

      # ~

      def _be_active
        @___is_active ||= __become_active
        NIL_
      end

      def __become_active

        @parent.dependencies.change_strategies(
          :downstream_context_receiver,
          :field_normalizer,
          :user_data_upstream_receiver,
          self )

        ACHIEVED_
      end

      ROLES___ = [
        :matrix_expresser,
        :unused_width_consumer,
      ]

      EVENTS___ = [
        :argument_bid_for,
        :before_first_row,
        :known_width,
        :receive_complete_field_list,
      ]

      # ~

      def receive_normalize_fields  # assume post-dup & field list complete

        fld_a = @_fld_a

        # see [#096.J] the cel pipeline

        # converts user datapoints into the arguments passed to celifiers:

        hsh = {}
        if fld_a
          fld_a.each_with_index do | fld, d |
            fld.stringifier_was_specified or next
            hsh[ d ] = fld.stringifier
          end
        end
        @_stringifiers = hsh

        # observes the results of above:

        @__string_observers = ::Hash.new do | h, d |
          h[ d ] = -> s do
            if s
              if @_widths[ d ] < s.length
                @_widths[ d ] = s.length
              end
            end
            NIL_
          end
        end

        # the default observational behavior on arguments is to track the width:

        @_widths = ::Hash.new 0

        # converts (celifier) "arguments" to cel strings:

        @_column_p = __build_proc_for_column_for
        @_celifiers = __build_celifiers_hash @_column_p

        @_deps.accept_by :receive_complete_field_list do | pl |
          pl.receive_complete_field_list fld_a
          KEEP_PARSING_
        end

        KEEP_PARSING_
      end

      def __build_celifiers_hash column_for

        fld_a = @_fld_a  # any

        ::Hash.new do | h, d |

          # the first time a celifier is called for a given column

          if fld_a
            fld = fld_a[ d ]
          end

          if fld
            p = fld.celifier_builder
          end

          p_ = if p

            col = column_for[ d ]

            _mtx = Me_the_Strategy_::Models__::ColumnMetrics.new(
              @_widths[ d ],
              col,
              col.field )

            p[ _mtx ]
          else
            __LR_celifier_for_width_and_field @_widths[ d ], fld
          end

          h[ d ] = p_  # we cache this decision so we don't make it
                       # again for this column on subsequent rows
          p_
        end
      end

      def __LR_celifier_for_width_and_field w, fld

        fmt = if fld && fld.is_right
          "%#{ w }s"
        else
          "%-#{ w }s"
        end
        -> s do
          fmt % s
        end
      end

      def receive_downstream_context o

        @_deps[ :matrix_expresser ].receive_downstream_context o

        # (when the above is too rigid, memoize the received argument here)
      end

      def receive_user_data_upstream st

        @_am = Table_Impl_::Models_::Argument_Matrix.new

        if st.no_unparsed_exists
          self._COVER_ME__when_no_user_data_rows
        else
          @_up_st = st
          __when_some_user_data_rows
        end
      end

      def __when_some_user_data_rows

        if @_do_calculation_pass
          __do_calculation_passes
        else
          _do_rendering_passes @_up_st
        end
      end

      def __do_calculation_passes  # (we would like this to go down)

        mutable = @_up_st.flush_remaining_to_array

        __calculation_pass_one mutable

        if @_formulas
          __calculation_pass_two mutable
        end

        _do_rendering_passes Common_::Polymorphic_Stream.via_array mutable
      end

      def __calculation_pass_one mutable

        # pass 1 - send all user datapoints to all user datapoint observers

        known_columns_count.times do | d |

          obs_a = @_column_data_observers[ d ]
          obs_a or next
          obs_a.each do | obs |
            _show_observer_the_money d, mutable, obs
          end
          NIL_
        end
      end

      def __calculation_pass_two mutable

        # pass 2 - for each column with a formula, run the formula on each row

        @_formulas.each_with_index do | p, d |

          p or next  # skip this column if it has no formula

          col = @_column_p[ d ]
          obs_a = @_column_data_observers[ d ]

          # for each row, replace the cel with the formula's result

          mutable.each do | mutable_row |

            mutable_row[ d ] = p[ mutable_row.dup.freeze, col ]
          end

          # because each cel down this *column* will be re-evaluated,
          # let any observers know that that's is what's happening

          if obs_a
            obs_a.each do | obs |
              obs.receive_column_was_re_evaluated
              _show_observer_the_money d, mutable, obs
            end
          end
        end
        NIL_
      end

      def _show_observer_the_money d, mutable, obs

        mutable.length.times do | row_d |
          obs.see_cel_argument mutable.fetch( row_d ).fetch( d )
        end
        NIL_
      end

      def _do_rendering_passes up_st

        @_deps.accept_by :before_first_row do | pl |
          pl.before_first_row
        end

        begin

          begin_argument_row

          _x_a = up_st.gets_one
          _x_a.each_with_index do | datapoint_x, d |

            had = true
            p = @_stringifiers.fetch d do
              had = false
            end
            if ! had
              p = DEFAULT_STRINGIFIER_
            end
            if p
              s = p[ datapoint_x ]
              s or self._SANITY
              receive_string s, d
            else
              receive_datapoint datapoint_x, d
            end
          end

          finish_argument_row

          if up_st.no_unparsed_exists
            break
          end
          redo
        end while nil

        __at_end_of_user_data
      end

      def __at_end_of_user_data

        if @_target_width && @_deps[ :unused_width_consumer ]
          __distribute_width
        end

        @_deps[ :matrix_expresser ].
          express_matrix_against_celifiers @_am, @_celifiers
      end

      def __distribute_width

        w = 0
        @_deps.accept_by :known_width do | pl |

          w += pl.known_width
          NIL_
        end

        w += @_widths.values.reduce( 0, & :+ )

        _available_width = @_target_width - w  # NOTE whether this
        # is negative, zero or positive we send it just the same.

        @_deps[ :unused_width_consumer ].receive_unused_width(
          _available_width, self )

        NIL_
      end

      # ~ The Service API

      ## ~~ field API

      def known_columns_count
        @_fld_a.length  # while it works..
      end

      def mutable_column_widths
        @_widths
      end

      def field_array
        @_fld_a
      end

      ## ~~ user datapoint observation API

      def add_column_data_observer obs, d  # assume post-dup

        @_do_calculation_pass = true
        @_formulas ||= nil
        @_column_data_observers ||= []
        a = @_column_data_observers[ d ]
        if ! a
          a = []
          @_column_data_observers[ d ] = a
        end
        a.push obs
        NIL_
      end

      ## ~~ column observation & writing API

      def set_formula d, & p  # assume post-dup

        @_do_calculation_pass = true
        a = ( @_formulas ||= [] )
        did = false
        a.fetch d do
          a[ d ] = p
          did = true
        end
        did or raise Definition_Conflict, __say_formula( d )
        NIL_
      end

      def __say_formula d
        "formula can only be set once for column at offset #{ d }"
      end

      def column_at d
        @_column_p[ d ]
      end

      def __build_proc_for_column_for  # assume post-dup

        cache = []

        p = -> d do  # assume fields and field

          col = cache[ d ]
          if ! col

            col = Me_the_Strategy_::Models__::Column.new do | cl |
              cl.receive_column_box __release_column_box d
              cl.field = @_fld_a[ d ]
              cl.receive_column_proc p
                # give this column the ability to access the other columns
            end
            cache[ d ] = col
          end
          col
        end
      end

      def __release_column_box d
        if @_col_bx
          @_col_bx.delete d
        end
      end

      def add_column_element x, sym, d

        h = ( @_col_bx ||= {} )

        _bx = h.fetch d do
          h[ d ] = Common_::Box.new
        end

        _bx.add sym, x

        NIL_
      end

      ## ~~ argument writing API

      def begin_argument_row

        @_am.begin_row
        NIL_
      end

      def receive_string s, d

        s or self._SANITY

        @__string_observers[ d ][ s ]
        @_am.accept_argument s, d
        NIL_
      end

      def receive_datapoint x, d

        @_am.accept_argument x, d
        NIL_
      end

      def finish_argument_row

        @_am.finish_row
        NIL_
      end

      ## ~~ stringifier API

      def touch_stringifier d, & p_p

        h = @_stringifiers
        none = false
        h.fetch d do
          none = true
        end
        if none
          p = p_p[]
          if p
            h[ d ] = p
          end
        end
        NIL_
      end

      ## ~~ dependency mutation API

      def receive_subscription dep, sym

        @_deps.add_subscriptions sym, dep
      end

      def touch_dynamic_dependency cls

        @_deps || _init_deps
        @_deps.touch_dynamic_dependency cls
      end

      # ~ ( end The Service API )

      def _init_deps

        o = Home_.lib_.plugin::Dependencies.new self
        o.roles = ROLES___
        o.emits = EVENTS___
        o.index_dependencies_in_module Table_Impl_::Row_Strategies_
        @_deps = o
        NIL_
      end
      Me_the_Strategy_ = self
    end
  end
end
