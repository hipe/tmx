require_relative '../../../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI - expr-fr - table - actor - fill" do

    extend TS_
    use :CLI_expression_frames_table_actor

    it "custom cel rederers can be built from field stats" do

      _DOT = "•"

      _celifier_builder = -> mtx do

        w = mtx.column_width

        -> s do

          margin = w - s.length

          if ( margin % 2 ).zero?
            right_num_dots = margin / 2
            left_num_dots = right_num_dots

          else
            margin -= 1
            right_num_dots = margin / 2
            left_num_dots = right_num_dots + 1
          end

          "#{ _DOT * left_num_dots }#{ s }#{ _DOT * right_num_dots }"
        end
      end

      subject_[
        :field, :label, "Subproduct",
          :celifier_builder, _celifier_builder,

        :field, :left, :label, "rating",

        :read_rows_from,
          [['face', 121], ['headless', 44], ['gazoink', 3]],
        * common_args_, :sep, '  ' ]

      gets_.should eql 'Subproduct  rating'
      gets_.should eql '•••face•••  121   '
      gets_.should eql '•headless•  44    '
      gets_.should eql '••gazoink•  3     '
      done_
    end

    it "tables can have a 'target_width' and use 'fill' fields with 'parts'" do

      _UNDR = '_'.freeze

      underscores = -> mtx do
        w = mtx.column_width
        -> cel do
          _UNDR * w
        end
      end

      subject_[
        :target_width, 40,

        :field,
          :fill, :parts, 2.8,
          :celifier_builder, underscores,

        :field,

        :field,
          :fill, :parts, 1.4,
          :celifier_builder, underscores,

        :header, :none,

        :read_rows_from, [[ nil, 'hi mom', nil], [nil, 'hello mother', nil]],

        * common_args_, :sep, EMPTY_S_ ]

      gets_.should eql '__________________hi mom      __________'
      gets_.should eql '__________________hello mother__________'
      done_
    end

    _FILL = -> mtx do
      char = mtx.field[ :fill ].glyph
      width = mtx.column_width
      -> _cel_ do
        char * width
      end
    end

    it "`glyph` (fill)" do

      subject_[

        :target_width, 7,

        :field,
          :fill, :glyph, 'a',
          :celifier_builder, _FILL,

        :field,

        :field,
          :fill, :glyph, 'c',
          :celifier_builder, _FILL,

        :header, :none,

        :read_rows_from, [[ nil, 'BBB', nil ]],
        * common_args_,
        :sep, EMPTY_S_,
      ]

      gets_.should eql 'aaBBBcc'
      done_
    end

    it "margins and separators count against available width for fill fields" do

      subject_[

        :field,
          :fill,
            :glyph, 'b',
          :celifier_builder, _FILL,

        :field,
          :fill,
            :glyph, 'd',
        :celifier_builder, _FILL,

        :header, :none,

        :read_rows_from, [[ nil, nil ]],

        :left, 'AA ', :sep, ' CC ', :right, ' EE',

        :write_lines_to, write_lines_to_,

        :target_width, 14,
      ]

      gets_.should eql 'AA bb CC dd EE'
      done_
    end

    it "left vs. right (patch/integration)" do

      subject_[
        :target_width, 20,
        :field, :right, :label, "Subproduct",
        :field, :left, :label, "num test files",
        :read_rows_from, [[ 'face', 121.0 ], [ 'headless', 33 ] ],
        :sep, '  ',
        * common_args_ ]

      gets_.should eql 'Subproduct  num test files'
      gets_.should eql '      face  121.0         '
      gets_.should eql '  headless  33            '  # note
      done_
    end
  end
end
