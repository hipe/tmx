# frozen_string_literal: true

require_relative '../test-support'

module Skylab::GitViz::TestSupport

  describe '[gv] magnetics - visual blame pieces via blame line stream' do

    # NOTE - originally this covered a magnet that existed. (note the name
    # and placement of this test file.) however, after we got things working
    # we discovered that our magnet was almost fully a dumb pass-thru magnet
    #
    # so we eliminated the magnet itself but left this test intact as a
    # contact point and demonstration of the requirements for our wrappers, etc.

    # #coverpoint1.1

    TS_[ self ]
    use :memoizer_methods

    it 'empty upstream - results in nothing, EMITS NOTHING' do  # #coverpoint1.3

      # (we assume that if the client upstream was empty, it did its own emission)

      _x = _go do
        _also width: 100
      end

      _x.nil? || fail
    end

    context 'span 4 HOUR blocks (mocked)' do

      # the point of this story is to see how
      #
      #   - even though we have ~20 screen tiles available for the viz part,
      #     the algorithm (which correctly finds the HOUR scale) wants only
      #     four of these tiles, to plot visually the 4 blocks (hours) that
      #     encompass the story.
      #
      #   - visually, one of these "tile columns" is empty
      #
      #   - but the header does its crazy thing

      it 'biz lines NEEDS' do
        _ = _biz_lines
        want_these_lines_in_array_ _ do |y|
          y << 'line 1'
          y << 'line two'
          y << 'line 3'
        end
      end

      it 'header lines' do
        _ = _header_lines
        want_these_lines_in_array_ _ do |y|
          y << "2 2 \n"
          y << "0D14\n"
          y << "1esA\n"
          y << "7ctM\n"
        end
      end

      it 'viz lines' do
        _ = _viz_lines
        want_these_lines_in_array_ _ do |y|
          y << 'Z   '
          y << '   Z'
          y << '  Z '
        end
      end

      shared_subject :_these_things do
        _go do
          _commit _SHA1, '2017-12-21 01:23:45 -0500'
          _commit _SHA2, '2017-12-21 03:23:45 -0500'
          _commit _SHA3, '2017-12-21 04:23:45 -0500'

          _line _SHA1, 'line 1'
          _line _SHA3, 'line two'
          _line _SHA2, 'line 3'

          _also(
            width: 30,
          )
        end
      end
    end

    context 'span 4 QUARTER (of year) blocks (mocked)' do

      # things to note in this story
      #
      #   - the visualization takes up much more of the available width
      #   - the header does its thing where it only labels occupied blocks-columns

      it 'biz lines' do
        _ = _biz_lines
        want_these_lines_in_array_ _ do |y|
          y << '  line A'
          y << Home_::EMPTY_S_
          y << 'line C'
        end
      end

      it 'header lines' do
        _ = _header_lines
        want_these_lines_in_array_ _ do |y|
          y << "22   2   2   2   \n"
          y << "00   0   0   0   \n"
          y << "11   1   1  Q1  Q\n"
          y << "34   5   6  47  4\n"
        end
      end

      it 'viz lines' do
        _ = _viz_lines
        want_these_lines_in_array_ _ do |y|
          y << 'Z                '
          y << '                Z'
          y << '            Z    '
        end
      end

      shared_subject :_these_things do
        _go do
          _commit _SHA1, '2013-12-21 01:23:45 -0500'
          _commit _SHA2, '2016-12-21 03:23:45 -0500'
          _commit _SHA3, '2017-12-21 04:23:45 -0500'

          _line _SHA1, '  line A'
          _line _SHA3, Home_::EMPTY_S_
          _line _SHA2, 'line C'

          _also(
            width: 30,
          )
        end
      end
    end

    #
    # the setup DSL
    #

    def _go

      @WIDEST_THING = 0
      @BLAME_LINES = []
      @COMMITS = {}
      @MUTEX = nil
      @PATH = 'doo-hah'

      yield

      sct = __call_thing
      if sct
        __testable_result_via_struct sct
      end
    end

    def __testable_result_via_struct sct

      _s_a = sct.header_lines
      viz_s_a = []
      biz_s_a = []

      # ~( #coverpoint1.2

      st = sct.slats_row_stream
      begin
        slats = st.gets
        slats || break
        _ = slats.business_slat.to_string
        biz_s_a.push _

        _ = slats.visualization_slat.to_string
        viz_s_a.push _
        redo
      end while above

      # ~)

      X_mvbp_ThisOneResult.new(
        _s_a,
        viz_s_a,
        biz_s_a,
      )
    end

    def __call_thing

      _these = @BLAME_LINES.map do |o|
        o.__line_
      end

      _this = remove_instance_variable :@WIDEST_THING


      _st = Home_::Stream_[ remove_instance_variable( :@BLAME_LINES ) ]

      _guy = Home_.lib_.brazen_NOUVEAU::RasterMagnetics::ScaledTimeLineItemStream_via_Glypher

      _guy.call_by(

        glyph: 'Z',
        column_order: %i( viz_column biz_column ),

        ** @ALSO,

        semimixed_item_stream: _st,

        business_column_max_width: _this,
        business_column_strings: _these,
      )
    end

    def _line sha_s, line

      w = line.length
      if @WIDEST_THING < w
        @WIDEST_THING = w
      end

      _lineno = @BLAME_LINES.length + 1
      ci = @COMMITS.fetch sha_s
      @BLAME_LINES.push X_mvbp_BlameLine.new( ci, _lineno, line )
    end

    def _commit sha_s, datetime_s
      Home_.lib_.date_time
      _datetime = ::DateTime.strptime datetime_s, '%Y-%m-%d %H:%M:%S %z'
      @COMMITS[ sha_s ] = X_mvbp_Commit.new( sha_s, _datetime, @PATH )
    end

    def _also **hh
      remove_instance_variable :@MUTEX
      @ALSO = hh
    end

    def _SHA1
      '123'
    end

    def _SHA2
      '456'
    end

    def _SHA3
      '789'
    end

    #
    #
    #

    def _viz_lines
      _these_things.viz_lines
    end

    def _biz_lines
      _these_things.biz_lines
    end

    def _join_header_lines
      _header_lines * Home_::EMPTY_S_
    end

    def _header_lines
      _these_things.header_lines
    end

    # ==

    class X_mvbp_BlameLine

      def initialize ci, d, s
        @commit = ci
        @lineno = d
        @line = s
        freeze
      end

      def __line_
        @line
      end

      def date_time_for_rasterized_visualization
        @commit.__date_time_
      end

      def count_towards_weight_for_rasterized_visualization
        0
      end
    end

    X_mvbp_Commit = ::Struct.new(
      :SHA_string_NOT_USED,
      :__date_time_,
      :path_NOT_USED,
    )

    X_mvbp_ThisOneResult = ::Struct.new(
      :header_lines,
      :viz_lines,
      :biz_lines,
    )

    # ==
    # ==
  end
end
# #born.
