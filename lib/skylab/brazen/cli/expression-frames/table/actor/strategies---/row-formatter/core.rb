module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    class Strategies___::Row_Formatter < Argumentative_strategy_class_[]

      SUBSCRIPTIONS = [ :arity_for, :init_dup ]

      PROPERTIES = [
        :argument_arity, :custom, :property, :field,
        :argument_arity, :one, :property, :header,
        :argument_arity, :one, :property, :left,
        :argument_arity, :one, :property, :right,
        :argument_arity, :one, :property, :target_width,
        :argument_arity, :one, :property, :sep,
      ]

      def initialize( * )
        @_do_header = nil
        @_fld_a = nil
        @_left_flank = nil
        @_role_box = Callback_::Box.new
        @_right_flank = nil
        @_separator_glyph = nil
        @_target_width = nil
        super
      end

      def initialize_dup _

        carry_over_dup_boundary_ CARRY_THESE_IVARS_OVER_THE_DUP_BOUNDARY___ do
          super
        end

        if @_fld_a  # treat fields as immutable but our list may grow or shrink
          @_fld_a = @_fld_a.dup
        end

        @_role_box = @_role_box.dup
      end

      CARRY_THESE_IVARS_OVER_THE_DUP_BOUNDARY___ = %i(
        @_do_header
        @_fld_a
        @_left_flank
        @_right_flank
        @_role_box
        @_separator_glyph
        @_target_width
      )

      def init_dup

        # once the parent has a complete graph of dependencies:

        @_role_box.each_value do | m |
          send m
        end
        KEEP_PARSING_
      end

      def receive_stream_after__field__ st

        fld = Me_the_Strategy_::Models__::Field.
          new_via_polymorphic_stream_passively st

        ( @_fld_a ||= [] ).push fld

        _be_table_receiver
      end

      def receive__header__argument x

        case x
        when :none
          @_do_header = false
          _be_table_receiver
        else
          raise ::ArgumentError
        end
      end

      def receive__left__argument x

        @_left_flank = x
        _be_table_receiver
      end

      def receive__right__argument x

        @_right_flank  = x
        _be_table_receiver
      end

      def receive__sep__argument x

        @_separator_glyph = x
        _be_table_receiver
      end

      def receive__target_width__argument x

        @_target_width = x
        __touch_fill
        KEEP_PARSING_
      end

      def receive_table

        @_column_widths = @_downstream_table_receiver.get_column_widths

        if @_target_width
          __assign_widths_to_fill_columns
        end

        if @_fld_a && false != @_do_header
          do_express_headers = true
        end

        if do_express_headers
          __add_field_labels_to_maxes
        end

        __init_celifiers
        __normalize_for_expression

        if do_express_headers
          __express_headers
        end

        __express_body
      end

      def __assign_widths_to_fill_columns

        self._K

        @_fld_a.each_with_index do | fld, d |
          fld.is_fill or next
          self._K
        end
        NIL_
      end

      def __add_field_labels_to_maxes

        mx = @_column_widths
        @_fld_a.each_with_index do | fld, d |
          w = mx[ d ]
          w_ = fld.some_label.length
          if w < w_
            mx[ d ] = w_
          end
        end
        NIL_
      end

      def __init_celifiers

        h = {}

        fld_a = @_fld_a

        @_column_widths.each_pair do | d, w |

          h[ d ] = __some_celifier_for_width_and_field( w, if fld_a
            fld_a[ d ]
          end )
        end

        @_celifiers = h
        NIL_
      end

      def __some_celifier_for_width_and_field w, fld

        if fld
          p = fld.celifier_builder
        end
        if p
          _wrap = Future_Proofer___.new w
          p[ _wrap ]
        else
          __LR_celifier_for_width_and_field w, fld
        end
      end

      Future_Proofer___ = ::Struct.new :column_width

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

      def __normalize_for_expression

        @_left_flank ||= LEFT_GLYPH_
        @_right_flank ||= RIGHT_GLYPH_
        @_separator_glyph ||= SEP_GLYPH_
        @_downstream_yielder_x = @_downstream_table_receiver.downstream_yielder_x
        NIL_
      end

      def __express_headers

        cx = @_celifiers

        _express_row( @_fld_a.each_with_index.map do | fld, d |
          cx.fetch( d )[ fld.some_label ]
        end )
      end

      def __express_body

        @_downstream_table_receiver.accept( & method( :_express_row ) )
        KEEP_PARSING_
      end

      def _express_row s_a

        _s_a_ = s_a.each_with_index.map do | s, d |
          @_celifiers.fetch( d )[ s ]
        end

        @_downstream_yielder_x <<
          "#{ @_left_flank }#{ _s_a_ * @_separator_glyph }#{ @_right_flank }"

        KEEP_PARSING_
      end

      # ~ experimental API-ish for roles (strategies)

      def _be_table_receiver

        @_role_box.touch :_table_ do
          _become_table_receiver
          :_become_table_receiver
        end
        KEEP_PARSING_  # important!
      end

      def __touch_fill

        @_role_box.touch :_fill_ do
          _change_row_receiver_to_fill
          :_change_row_receiver_to_fill
        end
      end

      def _change_row_receiver_to_fill

        _fr = _row_first_receiver
        _fr.replace_row_receiver_by do | prev |
          _curr = Table_Impl_::Cel_Strategies_::Fill::Row_Receiver.new prev
          _curr
        end

        ACHIEVED_
      end

      def _become_table_receiver

        _fr = _row_first_receiver

        @_downstream_table_receiver = _fr.replace_table_receiver self

        ACHIEVED_
      end

      def _row_first_receiver

        disp = @resources.dispatcher

        _id_of_row_first_receiver =
          disp.subscriptions.fetch( :receive_user_row ).first

        disp.retrieve_plugin _id_of_row_first_receiver
      end

      Me_the_Strategy_ = self
    end
  end
end
