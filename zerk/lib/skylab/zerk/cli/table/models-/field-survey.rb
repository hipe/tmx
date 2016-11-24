module Skylab::Zerk

  module CLI::Table

    class Models_::FieldSurvey < Tabular_::Models::FieldSurvey

      class Choices

        def initialize ps
          @page_size = ps
        end

        def field_survey_class
          This_
        end

        def hook_mesh
          NOTHING_  # use default
        end

        attr_reader(
          :page_size,
        )
      end

      # ==
      # -

        def initialize mesh
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

          d, d_ = _thing_ding( -f )
          _see_left_side_etc( d + 1 )
          _see_right_side_etc d_
          maybe_widen_width_of_widest_string d + d_ + 2  # sign, decimal
          super
        end

        def on_typeish_positive_nonzero_float f

          d, d_ = _thing_ding f
          _see_left_side_etc d
          _see_right_side_etc d_
          maybe_widen_width_of_widest_string d + d_ + 1  # decimal
          super
        end

        def _thing_ding positive_f  # WARNING positive or inf loop

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

        attr_reader(
          :the_maximum_number_of_characters_ever_seen_left_of_the_decimal,
          :the_maximum_number_of_digits_ever_seen_to_the_right_of_the_decimal,
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
