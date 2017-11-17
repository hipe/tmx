require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI table - fill fields intro" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_table

    build_string_repeater = -> col_offset, col_rsx do

      w = col_rsx.width_allocated_for_this_column

      -> cel_rsx do

        s = cel_rsx.row_typified_mixed_at_field_offset_softly( col_offset ).value

        s.length.nonzero? || fail

        buffer = s.dup
        while w > buffer.length
          buffer << s
        end

        if buffer.length > w
          buffer[ w .. -1 ] = EMPTY_S_
        end

        buffer
      end
    end

    build_arrow_thinger = -> col_offset, col_rsx do

      w = col_rsx.width_allocated_for_this_column

      -> cel_rsx do

        s = cel_rsx.row_typified_mixed_at_field_offset_softly( col_offset ).value

        d = w - s.length
        d > 0 || fail

        left_buffer = '>'
        d -= 1
        if d.nonzero?
          right_buffer = '<'
          d -= 1
          begin
            d.zero? && break
            left_buffer << '-'
            d -= 1
            d.zero? && break
            right_buffer << '-'
            d -= 1
            redo
          end while above
        end

        left_buffer = left_buffer.reverse
        "#{ left_buffer }#{ s }#{ right_buffer }"
      end
    end

    context "a fill field can be used to take up any remaining width" do

      it "(builds) (by the way - it's a special kind of summary field)" do
        design_ish_
      end

      it "looks good normally" do

        _matr = [
          %w( hi ),
          %w( wee ),
        ]

        against_matrix_want_lines_ _matr do |y|
          y << '| hihihih | hi  |'
          y << '| weeweew | wee |'
        end
      end

      it "you have to render something even if its only one cel wide" do

        _matr = [
          %w( hi ),
          %w( wee123456 ),
        ]

        against_matrix_want_lines_ _matr do |y|
          y << '| h | hi        |'
          y << '| w | wee123456 |'
        end
      end

      it "but if there's not enough room for it, we put blank strings" do

        _matr = [
          %w( hi ),
          %w( wee1234567 ),
        ]

        against_matrix_want_lines_ _matr do |y|
          y << '|  | hi         |'
          y << '|  | wee1234567 |'
        end
      end

      shared_subject :design_ish_ do

        table_module_.default_design.redefine do |defn|

          defn.add_field(
            :fill_field,
            :order_of_operation, 0,
          ) do |col_rsx|
            build_string_repeater[ 1, col_rsx ]
          end

          defn.add_field

          defn.target_final_width 17
        end
      end
    end

    context "you can specificy multiple fill fields" do

      it "(builds)" do
        design_ish_
      end

      it "work normally" do

        _matr = [
          %w( ya ),
          %w( yes ),
        ]

        against_matrix_want_lines_ _matr do |y|
          y << '| -->yayayaya<-- | yayayaya | ya  |'
          y << '| -->yesyesye<-- | yesyesye | yes |'
        end

        # target width is 35. take away all separators (10 width), leaves 25.
        # width for input data cel is 3, leaves 22. distribute 22 among
        # 7 parts and 4 parts. 7+4 = 11, the denominator.
        #
        #     7.0 / 11 * 22    # => 14.0
        #     4.0 / 11 * 22    # => 8.0
      end

      it "if there's not enough room for both of them, we won't pick favorites" do

        _matr = [
          %w( beeboo ),
          %w( 012345678901234567890123 ),
        ]

        against_matrix_want_lines_ _matr do |y|

          ss = "|  |  | beeboo                   |"
          y << ss
          y << "|  |  | 012345678901234567890123 |"
          ss.length == 34 || fail  # this is one less than the target width,
          # meaning there was one cel to spare but we did not use it.
        end
      end

      shared_subject :design_ish_ do

        table_module_.default_design.redefine do |defn|

          defn.add_field(
            :fill_field,
            :order_of_operation, 1,
            :parts, 7,
          ) do |col_rsx|
            build_arrow_thinger[ 1, col_rsx ]
          end

          defn.add_field(
            :fill_field,
            :order_of_operation, 0,
            :parts, 4,
          ) do |col_rsx|
            build_string_repeater[ 2, col_rsx ]
          end

          defn.add_field

          defn.target_final_width 35
        end
      end
    end
  end
end
# #tombstone: simple centering algorithm for mocking a fill; test for `glyph`
