module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    class Strategies___::Row_Formatter

      ARGUMENTS = [
        :argument_arity, :custom, :property, :field,
        :argument_arity, :one, :property, :target_width
      ]

      ROLES = nil

      Table_Impl_::Strategy_::Has_arguments[ self ]

      # ~

      def initialize x

        @_deps = nil
        @_fld_a = nil
        @parent = x
        @_target_width = nil
      end

      def dup x

        otr = super()
        otr.__init_dup x
        otr
      end

      def __init_dup x

        if @_deps
          @_deps = @_deps.dup self
        end

        if @_fld_a  # assume fields themselves are immutable-ish
          @_fld_a = @_fld_a.dup
        end

        @parent = x

        # @_target_width  keep
        NIL_
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
        :argument_matrix_expresser,
        :unused_width_consumer,
      ]

      EVENTS___ = [
        :argument_bid_for,
        :before_first_row,
        :known_width,
        :receive_complete_field_list,
      ]

      # ~

      def receive_normalize_fields  # assume the list of fields is complete

        # observes raw values of certain columns in user-provided rows:

        @_user_datapoint_observers = MONADIC_EMPTINESS_

        # converts user datapoints into the arguments passed to celifiers:

        @_argument_normalizers = ::Hash.new DEFAULT_NORMALIZER___

        # observes the results of above:

        @_argument_observers = ::Hash.new do | h, d |
          h[ d ] = -> s do
            if @_widths[ d ] < s.length
              @_widths[ d ] = s.length
            end
            NIL_
          end
        end

        # the default observational behavior on arguments is to track the width:

        @_widths = ::Hash.new 0

        # converts (celifier) "arguments" to cel strings:

        @_celifiers = __build_celifiers_hash

        a = @_fld_a

        @_deps.accept_by :receive_complete_field_list do | pl |
          pl.receive_complete_field_list a
          KEEP_PARSING_
        end

        KEEP_PARSING_
      end

      DEFAULT_NORMALIZER___ = -> x do
        x.to_s  # nil OK, false OK
      end

      def __build_celifiers_hash

        fld_a = @_fld_a  # any

        ::Hash.new do | h, d |

          # the first time a celifier is called for a given column

          if fld_a
            fld = fld_a[ d ]
          end

          if fld
            p = fld.celifier_builder
          end

          w = @_widths[ d ]

          p_ = if p
            p[ Column_Metrics___.new( w, fld ) ]
          else
            __LR_celifier_for_width_and_field w, fld
          end

          h[ d ] = p_  # we cache this decision so we don't make it
                       # again for this column on subsequent rows
          p_
        end
      end

      Column_Metrics___ = ::Struct.new :column_width, :field

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

        @_deps[ :argument_matrix_expresser ].receive_downstream_context o

        # (when the above is too rigid, memoize the received argument here)
      end

      def receive_user_data_upstream st

        @_am = Table_Impl_::Models_::Argument_Matrix.new

        if st.no_unparsed_exists
          __when_no_user_data_rows
        else
          @_up_st = st
          __when_some_user_data_rows
        end
      end

      def __when_some_user_data_rows

        @_deps.accept_by :before_first_row do | pl |
          pl.before_first_row
        end

        begin

          begin_argument_row

          _x_a = @_up_st.gets_one

          _x_a.each_with_index do | x, d |

            p_a = @_user_datapoint_observers[ d ]
            if p_a
              self._YAY
            end

            _x_ = @_argument_normalizers[ d ][ x ]

            receive_celifier_argument _x_, d
          end

          finish_argument_row

          if @_up_st.no_unparsed_exists
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

        @_deps[ :argument_matrix_expresser ].
          express_argument_matrix_against_celifiers @_am, @_celifiers
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

      # ~ service API

      def known_columns_count

        @_fld_a.length  # while it works..
      end

      def field_array

        @_fld_a
      end

      def mutable_column_widths
        @_widths
      end

      def begin_argument_row

        @_am.begin_row
        NIL_
      end

      def receive_celifier_argument x, d

        @_argument_observers[ d ][ x ]
        @_am.accept_argument x, d
        NIL_
      end

      def finish_argument_row

        @_am.finish_row
        NIL_
      end

      def receive_subscription dep, sym

        @_deps.add_subscriptions sym, dep
      end

      def touch_dynamic_dependency cls

        @_deps || _init_deps
        @_deps.touch_dynamic_dependency cls
      end

      # ~

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
