require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI table - fill fields intro" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_table

    repeat_the_string_at_column = -> col_offset, o do

      w = o.available_width_for_this_column

      s = o.row_typified_mixed_at( col_offset ).value

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

    do_the_arrow_thing = -> col_offset, o do
      w = o.available_width_for_this_column
      s = o.row_typified_mixed_at( col_offset  ).value

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

    context "a fill field can be used to take up any remaining width" do

      it "(builds) (by the way - it's a special kind of summary field)" do
        design_ish_
      end

      it "looks good normally" do

        _matr = [
          %w( hi ),
          %w( wee ),
        ]

        against_matrix_expect_lines_ _matr do |y|
          y << '| hihihih | hi  |'
          y << '| weeweew | wee |'
        end
      end

      it "you have to render something even if its only one cel wide" do

        _matr = [
          %w( hi ),
          %w( wee123456 ),
        ]

        against_matrix_expect_lines_ _matr do |y|
          y << '| h | hi        |'
          y << '| w | wee123456 |'
        end
      end

      it "but if there's not enough room for it, we put blank strings" do

        _matr = [
          %w( hi ),
          %w( wee1234567 ),
        ]

        against_matrix_expect_lines_ _matr do |y|
          y << '|  | hi         |'
          y << '|  | wee1234567 |'
        end
      end

      shared_subject :design_ish_ do

        table_module_.default_design.redefine do |defn|

          defn.add_field(
            :fill_field,
            :order_of_operation, 0,
          ) do |o|
            repeat_the_string_at_column[ 1, o ]
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

        against_matrix_expect_lines_ _matr do |y|
          y << '| -->yayayaya<-- | yayayaya | ya  |'
          y << '| -->yesyesye<-- | yesyesye | yes |'
        end
      end

      it "if there's not enough room for both of them, we won't pick favorites" do

        _matr = [
          %w( beeboo ),
          %w( 012345678901234567890123 ),
        ]

        against_matrix_expect_lines_ _matr do |y|

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
          ) do |o|
            do_the_arrow_thing[ 1, o ]
          end

          defn.add_field(
            :fill_field,
            :order_of_operation, 0,
            :parts, 4,
          ) do |o|
            repeat_the_string_at_column[ 2, o ]
          end

          defn.add_field

          defn.target_final_width 35
        end
      end
    end
  end
end
# #tombstone: simple centering algorithm for mocking a fill; test for `glyph`
