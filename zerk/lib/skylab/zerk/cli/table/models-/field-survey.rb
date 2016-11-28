module Skylab::Zerk

  module CLI::Table

    class Models_::FieldSurvey < Tabular_::Models::FieldSurvey

      class Choices  # 1x

        def initialize foa, at_page_end_p, at_end_p, design

          @field_surveyor = MyFieldSurveyor___.new design

          @field_observers_array = foa
          @hook_for_end_of_mixed_tuple_stream = at_end_p
          @hook_for_end_of_page = at_page_end_p
          @page_size = design.page_size
        end

        def page_magnetic_function
          NOTHING_  # use default
        end

        attr_reader(
          :field_observers_array,
          :field_surveyor,
          :hook_for_end_of_mixed_tuple_stream,
          :hook_for_end_of_page,
          :page_size,
        )
      end

      # ==

      class MyFieldSurveyor___

        def initialize design

          @__design = design

          @__hook_mesh =
            Tabular_::Magnetics::SurveyedPage_via_MixedTupleStream::HOOK_MESH
        end

        def build_new_survey_for_input_offset d

          if d
            _fld = @__design.defined_field_for_input_offset__ d
          end

          This_.begin _fld, @__hook_mesh
        end
      end

      # ==
      # -

        # (a fair portion of this is see [#050.A] widths of columns with floats)

        def initialize field, mesh

          if field
            sprintf_h = field.sprintf_hash
          end
          @_sprintf_hash = sprintf_h || MONADIC_EMPTINESS_

          @_see_positive_nonzero_float = :__see_first_positive_nonzero_float
          @_see_negative_nonzero_float = :__see_first_negative_nonzero_float


          @_custom_float_format_was_used = false
          @the_maximum_number_of_characters_ever_seen_left_of_the_decimal = 0
          @the_maximum_number_of_digits_ever_seen_to_the_right_of_the_decimal = 0

          super mesh
        end

        # ~ strings (nothing else needed)


        # ~ symbols

        def on_typeish_symbol sym
          maybe_widen_width_of_widest_string sym.length  # yay
          super
        end

        # ~ floats

        def on_typeish_negative_nonzero_float f
          send @_see_negative_nonzero_float, f
          super
        end

        def on_typeish_positive_nonzero_float f
          send @_see_positive_nonzero_float, f
          super
        end

        def __see_first_negative_nonzero_float f
          if _has_custom_float_formatter
            _see_this_and_future_floats_via_custom_formatter f
          else
            _see_floats_normally
            send @_see_negative_nonzero_float, f
          end
        end

        def __see_first_positive_nonzero_float f
          if _has_custom_float_formatter
            _see_this_and_future_floats_via_custom_formatter f
          else
            _see_floats_normally
            send @_see_positive_nonzero_float, f
          end
        end

        def _has_custom_float_formatter
          x = @_sprintf_hash[ :nonzero_float ]
          if x
            @HAS_CUSTOM_FLOAT_FORMAT = true
            @CUSTOM_FLOAT_FORMAT = x ; ACHIEVED_
          end
        end

        def _see_this_and_future_floats_via_custom_formatter f

          # "the delicate art of custom formats" :[#050.D]

          @_custom_float_format_was_used = true

          _throwaway = @CUSTOM_FLOAT_FORMAT % f

          w = _throwaway.length

          # maybe_widen_width_of_widest_string w  happens #here

          @WIDTH_OF_VALUE_AS_STRING_FROM_CUSTOM_FLOAT_FORMAT = w

          _see_floats_normally
          if 0.0 < f  # calculation repeated. meh
            send @_see_positive_nonzero_float, f
          else
            send @_see_negative_nonzero_float, f
          end
          NIL
        end

        def _see_floats_normally
          @_see_negative_nonzero_float = :__see_negative_nonzero_float_normally
          @_see_positive_nonzero_float = :__see_positive_nonzero_float_normally
        end

        def __see_negative_nonzero_float_normally f
          d, d_ = _left_width_and_right_width_of_POSITIVE_float( -f )
          _see_left_side_etc( d + 1 )
          _see_right_side_etc d_
        end

        def __see_positive_nonzero_float_normally f
          d, d_ = _left_width_and_right_width_of_POSITIVE_float f
          _see_left_side_etc d
          _see_right_side_etc d_
        end

        def _left_width_and_right_width_of_POSITIVE_float positive_f  # WARNING positive or inf loop

          Basic_::Number.
            of_digits_before_and_after_decimal_in_positive_float(
              positive_f, MAX_RIGHT_DIGITS__ )
        end

        # ~ ints

        def on_typeish_negative_nonzero_integer int_d

          d = Basic_::Number.of_digits_in_positive_integer( - int_d )
          d += 1  # sign
          _see_left_side_etc d
          maybe_widen_width_of_widest_string d
          super
        end

        def on_typeish_positive_nonzero_integer int_d

          d = Basic_::Number.of_digits_in_positive_integer int_d
          _see_left_side_etc d
          maybe_widen_width_of_widest_string d
          super
        end

        def on_typeish_zero _
          _see_left_side_etc 1
          maybe_widen_width_of_widest_string 1
          super
        end

        # ~ numeric support

        def _see_left_side_etc d
          if @the_maximum_number_of_characters_ever_seen_left_of_the_decimal < d
            @the_maximum_number_of_characters_ever_seen_left_of_the_decimal = d
          end
        end

        def _see_right_side_etc d
          if @the_maximum_number_of_digits_ever_seen_to_the_right_of_the_decimal < d
            @the_maximum_number_of_digits_ever_seen_to_the_right_of_the_decimal = d
          end
        end

        # ~

        def on_typeish_boolean b
          maybe_widen_width_of_widest_string( b ? 4 : 5 )  # THE WORST  see #table-spot-1
          super
        end

        # ~

        # --

        def finish

          # you must read [#050.A]. lots of custom work for floats and/or
          # formats at end of page. :#table-spot-3

          if @number_of_nonzero_floats.nonzero?

            if @_custom_float_format_was_used

              maybe_widen_width_of_widest_string @WIDTH_OF_VALUE_AS_STRING_FROM_CUSTOM_FLOAT_FORMAT

            else
              __finish_measuring_floats_normally
            end
          end

          super
        end

        def __finish_measuring_floats_normally

          _left_width =
            @the_maximum_number_of_characters_ever_seen_left_of_the_decimal

          _right_width =
            @the_maximum_number_of_digits_ever_seen_to_the_right_of_the_decimal

          sum = _left_width + 1 + _right_width  # 1 for '.'

          @__WoICC_kn = Common_::Known_Known[ sum ]

          maybe_widen_width_of_widest_string sum

          NIL
        end

        # --

        def width_of_imaginary_content_column_
          @__WoICC_kn.value_x
        end

        attr_reader(
          :the_maximum_number_of_characters_ever_seen_left_of_the_decimal,
          :the_maximum_number_of_digits_ever_seen_to_the_right_of_the_decimal,

          :CUSTOM_FLOAT_FORMAT,
          :HAS_CUSTOM_FLOAT_FORMAT,
          :WIDTH_OF_VALUE_AS_STRING_FROM_CUSTOM_FLOAT_FORMAT,
        )
      # -
      # ==

      Basic_ = Home_.lib_.basic
      MAX_RIGHT_DIGITS__ = 4  # this could be refined to take into acct range
      This_ = self
    end
  end
end
# #born: during unification as a replacement for hacky string math on floats
