require_relative '../../../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI - expr-fr - table - actor - max-share" do

    extend TS_
    use :CLI_expression_frames_table_actor

    _PERCENT_SHARE = -> mtx do

      glyph = mtx.field[ :fill ].glyph
      width = mtx.column_width

      -> max_share_f do

        if max_share_f  # none for header row

          num_pluses = ( max_share_f * width ).floor
          _num_spaces = width - num_pluses
          "#{ glyph * num_pluses }#{ SPACE_ * _num_spaces }"
        end
      end
    end

    it "'max share meter' done manually" do

      subject_[

        :target_width, 43,

        :field, :right, :label, "Subproduct",

        :field, :left,
          :gather_statistics,
          :label, "num test files",

        :field,

          :fill, :glyph, '+',

          :formula, -> row, col do
            1.0 * row[ 1 ] / col.column_at( 1 )[ :stats ].numeric_max
          end,

          :stringifier, nil,  # pass the above value thru

          :celifier_builder, _PERCENT_SHARE,

        :read_rows_from, [[ 'face', 121, nil ], [ 'headless', 44.0, nil ]],

        :sep, '  ', * common_args_ ]

      gets_.should eql 'Subproduct  num test files  '
      gets_.should eql '      face  121             +++++++++++++++'
      gets_.should eql '  headless   44.0           +++++          '
      done_
    end

    it "'max share meter' as a builtin" do

      subject_[

        :target_width, 43,

        :field, :right, :label, "Subproduct",

        :field,
          :right,
          :label, "num test files",

        :field,

          # (the order is particular below, of the first few terms)

          :gather_statistics,
          :max_share_meter,
          :of_column, 2,  # same column as the one with "gather statistics"
          :glyph, '•',
          :background_glyph, '-',
          :from_right,

        :read_rows_from,
          [[ 'face', 121, 121 ],
           [ 'headless', 44.0, 44 ],
           [ '(total)', 165.0, nil ]],

        :sep, '  ', * common_args_ ]

      gets_.should eql 'Subproduct  num test files  '
      gets_.should eql '      face             121  •••••••••••••••'  # for now
      gets_.should eql '  headless            44.0  ----------•••••'
      gets_.should eql '   (total)           165.0  '

      done_
    end
  end
end
