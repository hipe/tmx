require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Table

  describe "[fa] CLI table" do

    it "custom cel rederers can be built from field stats" do
      _DOT = "•"
      subproduct_renderer_builder = -> column do
        max_strlen = column.stats.max_strlen
        column.width.should eql max_strlen
        -> cel do
          overage = max_strlen - cel.as_string.length
          if ( overage % 2 ).zero?
            right_num_dots = left_num_dots = overage / 2
          else
            overage -= 1
            right_num_dots = overage / 2
            left_num_dots = right_num_dots + 1
          end
          "#{ _DOT * left_num_dots }#{ cel.as_string }#{
            }#{ _DOT * right_num_dots }"
        end
      end

      Subject__[][
        :field, :label, "Subproduct",
          :cel_renderer_builder, subproduct_renderer_builder,
        :field, :left, :label, "rating",
        :read_rows_from,
          [['face', 121], ['headless', 44], ['gazoink', 3]],
        * standard, :sep, '  ' ]
      a = release_lines
      a.shift.should eql 'Subproduct  rating'
      a.shift.should eql '•••face•••  121   '
      a.shift.should eql '•headless•  44    '
      a.shift.should eql '••gazoink•  3     '
      a.length.should be_zero
    end

    it "tables can have a 'target_width' and use 'fill' fields with 'parts'" do
      _UNDR = '_'.freeze
      underscores = -> column do
        width = column.width
        -> cel do
          _UNDR * width
        end
      end
      Subject__[][
        :target_width, 40,
        :field, :fill, :parts, 2.8, :cel_renderer_builder, underscores,
        :field,
        :field, :fill, :parts, 1.4, :cel_renderer_builder, underscores,
        :header, :none,
        :read_rows_from, [[ nil, 'hi mom', nil], [nil, 'hello mother', nil]],
        * standard, :sep, '' ]
      a = release_lines
      a.shift.should eql '__________________hi mom      __________'
      a.shift.should eql '__________________hello mother__________'
      a.length.should be_zero
    end

    _FILL = -> column do
      char = column.field.fill.with_x
      width = column.width
      -> _cel_ do
        char * width
      end
    end

    it "the 'fill' function can take 1 arbitrary 'with' argument" do
      Subject__[][
        :target_width, 7,
        :field, :fill, :with, 'a', :cel_renderer_builder, _FILL,
        :field,
        :field, :fill, :with, 'c', :cel_renderer_builder, _FILL,
        :header, :none,
        :read_rows_from, [[ nil, 'BBB', nil ]],
        * standard, :sep, '' ]
      a = release_lines
      a.shift.should eql 'aaBBBcc'
      a.length.should be_zero
    end

    it "margins and separators count against available width for fill fields" do
      Subject__[][
        :target_width, 14,
        :field, :fill, :with, 'b', :cel_renderer_builder, _FILL,
        :field, :fill, :with, 'd', :cel_renderer_builder, _FILL,
        :header, :none,
        :read_rows_from, [[ nil, nil ]],
        :left, 'AA ', :sep, ' CC ', :right, ' EE',
        :write_lines_to, write_lines_to ]
      a = release_lines
      a.shift.should eql 'AA bb CC dd EE'
      a.length.should be_zero
    end

    it "left vs. right (patch)" do
      Subject__[][
        :target_width, 20,
        :field, :right, :label, "Subproduct",
        :field, :left, :label, "num test files",
        :read_rows_from, [[ 'face', 121.0 ], [ 'headless', 33 ] ],
        :sep, '  ', * standard ]
      a = release_lines
      a.shift.should eql 'Subproduct  num test files'
      a.shift.should eql '      face  121.0         '
      a.shift.should eql '  headless  33.0          '
      a.length.should be_zero
    end

    _SPACE = ' '.freeze

    _PERCENT_SHARE = -> column do
      max = column.stats.max_numeric_x.to_f
      width = column.width
      char = column.field.fill.with_x
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
      Subject__[][
        :target_width, 43,
        :field, :right, :label, "Subproduct",
        :field, :left, :label, "num test files",
        :field, :fill, :with, '+',
          :cel_renderer_builder, _PERCENT_SHARE,
        :read_rows_from, [['face', 121, 121 ], [ 'headless', 44.0, 44]],
        :sep, '  ', * standard ]
      a = release_lines
      a.shift.should eql 'Subproduct  num test files  '
      a.shift.should eql '      face  121.0           +++++++++++++++'
      a.shift.should eql '  headless  44.0            +++++          '
      a.length.should be_zero
    end

    it "'max share meter' as a builtin" do
      Subject__[][
        :target_width, 43,
        :field, :right, :label, "Subproduct",
        :field, "num test files",
        :field, :cel_renderer_builder, :max_share_meter,
          :fill, :with, [ :from_right, :glyph, '•', :background_glyph, '-' ],
        :read_rows_from,
          [['face', 121, 121 ], [ 'headless', 44.0, 44], ['(total)', 165.0]],
        :sep, '  ', * standard ]
      a = release_lines
      a.shift.should eql 'Subproduct  num test files                 '
      a.shift.should eql '      face           121.0  •••••••••••••••'
      a.shift.should eql '  headless            44.0  ----------•••••'
      a.shift.should eql '   (total)           165.0'
      a.length.should be_zero
    end

    def standard
      [ :write_lines_to, write_lines_to, :left, '', :right, '' ]
    end

    def write_lines_to
      ( @y ||= [] ).method :push
    end

    def release_lines
      a = @y ; @y = nil ; a
    end
  end
end
