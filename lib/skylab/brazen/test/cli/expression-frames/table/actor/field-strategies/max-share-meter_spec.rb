require_relative '../../../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI - expr-fr - table - actor - max-share", wip: true do

    _PERCENT_SHARE = -> column_metrics do
      max = column_metrics.stats.max_numeric_x.to_f
      width = column_metrics.width
      char = column_metrics.field.fill.with_x
      -> cel do
        if cel
          _max_share = cel.x / max
          num_pluses = ( _max_share * width ).floor
          num_spaces = width - num_pluses
          "#{ char * num_pluses }#{ _SPACE * num_spaces }"
        end
      end
    end

    it "'max share meter' done manually" do

      _subject[
        :target_width, 43,
        :field, :right, :label, "Subproduct",
        :field, :left, :label, "num test files",
        :field, :fill, :with, '+',
          :celifier_builder, _PERCENT_SHARE,
        :read_rows_from, [['face', 121, 121 ], [ 'headless', 44.0, 44]],
        :sep, '  ', * standard ]

      _gets.should eql 'Subproduct  num test files  '
      _gets.should eql '      face  121.0           +++++++++++++++'
      _gets.should eql '  headless  44.0            +++++          '
      _done
    end

    it "'max share meter' as a builtin" do

      _subject[
        :target_width, 43,
        :field, :right, :label, "Subproduct",
        :field, "num test files",
        :field, :celifier_builder, :max_share_meter,
          :fill, :with, [ :from_right, :glyph, '•', :background_glyph, '-' ],
        :read_rows_from,
          [['face', 121, 121 ], [ 'headless', 44.0, 44], ['(total)', 165.0]],
        :sep, '  ', * standard ]

      _gets.should eql 'Subproduct  num test files                 '
      _gets.should eql '      face           121.0  •••••••••••••••'
      _gets.should eql '  headless            44.0  ----------•••••'
      _gets.should eql '   (total)           165.0'
      _done
    end
  end
end
