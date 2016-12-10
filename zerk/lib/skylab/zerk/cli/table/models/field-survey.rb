module Skylab::Zerk

  module CLI::Table

    Require_tabular_[]

    class Models::FieldSurvey < Tabular_::Models::FieldSurvey

      class MyFieldSurveyor  # 1x

        def initialize design

          @__design = design

          @__hook_mesh =
            Tabular_::Magnetics::PageSurvey_via_MixedTupleStream::HOOK_MESH
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
          @_sprintf_hash = sprintf_h  # can be nil

          super mesh
        end

        def clear_survey  # called 1x during initialize, Nx after

          @_custom_format_related = nil

          @_see_positive_nonzero_float = :__see_first_positive_nonzero_float
          @_see_negative_nonzero_float = :__see_first_negative_nonzero_float

          @the_maximum_number_of_characters_ever_seen_left_of_the_decimal = 0
          @the_maximum_number_of_digits_ever_seen_to_the_right_of_the_decimal = 0

          super
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
          @_sprintf_hash and @_sprintf_hash.key? :nonzero_float
        end

        def _see_this_and_future_floats_via_custom_formatter f

          # "the delicate art of custom formats" :[#050.D]

          format = @_sprintf_hash.fetch :nonzero_float

          _throwaway = format % f

          # maybe_widen_width_of_widest_string w  happens #here

          ( @_custom_format_related ||= {} )[ :nonzero_float ] =
            CustomFormatRelated___.new _throwaway.length, format

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

            if self.CUSTOM_FLOAT_FORMAT_WAS_USED

              _w = self.WIDTH_OF_VALUE_AS_STRING_FROM_CUSTOM_FLOAT_FORMAT

              maybe_widen_width_of_widest_string _w  # :#here

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

        # -- read

        def WIDTH_OF_VALUE_AS_STRING_FROM_CUSTOM_FLOAT_FORMAT
          @_custom_format_related[ :nonzero_float ].
            presumably_representative_width_of_value_as_string
        end

        def CUSTOM_FLOAT_FORMAT_WAS_USED  # in caps because VERY experimental
          @_custom_format_related && @_custom_format_related[ :nonzero_float ]
        end

        def CUSTOM_FLOAT_FORMAT  # assume
          @_custom_format_related.fetch( :nonzero_float ).format
        end

        def width_of_imaginary_content_column_
          @__WoICC_kn.value_x
        end

        attr_reader(
          :the_maximum_number_of_characters_ever_seen_left_of_the_decimal,
          :the_maximum_number_of_digits_ever_seen_to_the_right_of_the_decimal,
        )
      # -
      # ==

      class CustomFormatRelated___

        # (these members used to be stored flatly in the parent subject,
        #  but clearing them out on `clear_survey` (on init) was pretty awful)

        def initialize d, fmt
          @presumably_representative_width_of_value_as_string = d
          @format = fmt
        end

        attr_reader(
          :format,
          :presumably_representative_width_of_value_as_string,
        )
      end

      # ==

      Basic_ = Home_.lib_.basic
      MAX_RIGHT_DIGITS__ = 4  # this could be refined to take into acct range
      This_ = self
    end
  end
end
# #born: during unification as a replacement for hacky string math on floats
