require_relative 'test-support'

module Skylab::GitViz::TestSupport

  describe "[gv] scale time" do

    TS_[ self ]
    use :operations_mocks
    use :double_decker_memoize

    it "annual - near minimal - one event" do

      using_scale_adapter :Annual

      at_times '2001-02-03T04:05:06+07:00'

      sparse_matrix [ nil ], nil, [ 23 ]

      _go
      _expect_headers '2001'
    end

    it "annual - three events into two adjacent buckets" do

      using_scale_adapter :Annual

      at_times '2001-02-03T04:05:06+07:00',
               '2002-01-09T02:03:07+05:00',
               '2002-12-31T-09T02:03:07+05:00'

      sparse_matrix [ 10, nil, 12 ], nil,
                    [ nil, 11, 13 ]
      _go
      _expect_headers '2001', '2002'
    end

    it "annual - three events into two non-adjacent buckets" do

      using_scale_adapter :Annual

      at_times '2001-02-03T04:05:06+07:00',
               '2003-01-09T02:03:07+05:00',
               '2003-12-31T-09T02:03:07+05:00'

      sparse_matrix [ 10, nil, 12 ], nil,
                    [ nil, 11, 13 ]
      _go
      _expect_headers '2001', '2002', '2003'
    end

    it "semi-annual - 2 adjacent with a year jump" do

      using_scale_adapter :Semi_Annual

      at_times '2001-07-03T04:05:06+07:00',
        '2002-01-01T-00:00:01+07:00'

      sparse_matrix [ 99, nil ], nil,
                    [ 98, 3 ]

      _go
      _expect_headers '2001', '2002'
    end

    it "semi-annual - Q1, Q2, Q3" do

      using_scale_adapter :Semi_Annual

      at_times '2001-02-03T04:05:06+07:00',
        '2001-05-03T04:05:06+07:00',
        '2001-08-03T04:05:06+07:00'

      sparse_matrix [ 3, nil, 3 ], nil,
                    [ nil, 50, 100 ]

      _go
      _expect_headers '2001', '2nd½'
    end

    it "quarterly - start at not the start, have some holes" do

      using_scale_adapter :Quarterly

      at_times '2001-02-03T04:05:06+07:00',  # y1 q1
        '2001-03-03T04:05:06+07:00',

        '2001-05-03T04:05:06+07:00',         # y1 q2

        '2001-10-03T04:05:06+07:00',         # y2 q4
        '2001-11-03T04:05:06+07:00',

        '2002-01-03T04:05:06+07:00',         # y2 q1
        '2002-03-03T04:05:06+07:00',

        '2002-06-03T04:05:06+07:00',         # y2 q3

        '2002-09-03T04:05:06+07:00'          # y2 q4

      sparse_matrix [ 1,   2, 3,   4, 5,   6,  7,   8,  9 ], nil,
                    [ 2, nil, 4, nil, 8, nil, 16, nil, 32 ]


      _go
      _expect_headers '2001', '  Q2', '    ', '  Q4', '2002', '  Q2', '  Q3'
    end

    it "monthly - skip first 2 months of the next year" do


      using_scale_adapter :Monthly

      at_times '2001-11-03T04:05:06+07:00', # m1
               '2001-11-30T04:05:06+07:00',
               '2001-12-31T04:05:06+07:00', # m2
               '2002-03-01T04:05:06+07:00', # m3
               '2002-04-01T04:05:06+07:00'  # m4

      sparse_matrix [ 1, 1, nil, 1, 1 ], nil,
                    [ 1, nil, 1, 1, 1 ]

      _go
      _expect_headers '2001', ' Dec', '2002', '    ', ' Mar', ' Apr'
    end

    it "weekly - etc" do

      using_scale_adapter :Weekly

      at_times '2001-12-20T04:05:06+07:00',
               '2001-12-30T04:05:06+07:00',
               '2002-01-06T04:05:06+07:00',
               '2002-01-07T04:05:06+07:00',
               '2002-01-08T04:05:06+07:00'

      sparse_matrix [ 1, 1, 1, 1, 1 ], nil,
                    [ 1, nil, 1, 1, 1 ]

      _go
      _expect_headers '2001', 'wk52', '2002', 'wk 2'
    end

    it "weekly - when the year turns over it displays it even if hole" do


      using_scale_adapter :Weekly
      at_times '2001-12-25T04:05:06+07:00',
               '2002-01-08T04:05:06+07:00'

      sparse_matrix [ 1, 1 ], nil,
                    [ 1, 1 ]

      _go
      _expect_headers '2001', '2002', 'wk 2'
    end

    it "daily - gets really interesting" do

      using_scale_adapter :Daily

      at_times '2001-02-06T04:05:06+07:00',
               '2001-02-07T04:05:06+07:00',
               '2001-02-08T04:05:06+07:00',
               '2001-02-09T04:05:06+07:00',

               '2001-02-12T04:05:06+07:00'

      sparse_matrix [ 1, nil, 1, 2, 3 ], nil,
                    [ nil, 1, nil, 2, 3 ]

      _go
      _expect_headers '2001', 'Feb ', ' 8th', ' Fri', 'Feb ', '11th', ' Mon'
    end

    it "daily - say sunday when you have to" do

      using_scale_adapter :Daily

      at_times '2001-02-06T04:05:06+07:00',  # (each item is + 1 day)
               '2001-02-07T04:05:06+07:00',
               '2001-02-08T04:05:06+07:00',
               '2001-02-09T04:05:06+07:00',
               '2001-02-10T04:05:06+07:00',
               '2001-02-11T04:05:06+07:00',
               '2001-02-12T04:05:06+07:00'

      sparse_matrix [ 1, 2, 3, 4, 5, 6, 7 ], nil,
                    [ 1, 2, 3, 4, 5, 6, 7 ]

      _go
      _expect_headers '2001', 'Feb ', ' 8th', ' Fri', ' Sat', ' Sun', ' Mon'
    end

    it "three shift - minimal iteresting" do

      using_scale_adapter :Three_Shift

      at_times '2001-02-06T04:05:06+07:00',
               '2001-02-06T09:05:06+07:00',
               '2001-02-06T17:05:06+07:00',

               '2001-02-07T04:05:06+07:00',

               '2001-02-07T09:05:06+07:00',
               '2001-02-07T17:05:06+07:00'

      sparse_matrix [ 1, 2, 3, 4, 5, 6 ], nil,
                    [ 1, 2, 3, 4, 5, 6 ]

      _go
      _expect_headers '2001', ' Feb', ' 6th', ' Wed', ' 8AM', ' 4PM'

    end

    it "three shift - sunday" do

      using_scale_adapter :Three_Shift

      at_times '2001-02-08T04:05:06+07:00',
               '2001-02-08T09:05:06+07:00',

               '2001-02-09T17:05:06+07:00',
               '2001-02-09T17:13:06+07:00',
               '2001-02-09T17:20:06+07:00',

               '2001-02-10T04:05:06+07:00',

               '2001-02-10T09:05:06+07:00',
               '2001-02-10T17:05:06+07:00',

               '2001-02-11T09:05:06+07:00',
               '2001-02-11T17:05:06+07:00'

      sparse_matrix [ 1, 2, 3, 4, 5, 6, 7, 8, 8, 10 ], nil,
                    [ 1, 2, 3, 4, 5, 6, 7, 8, 8, 10 ]

      _go
      _expect_headers '2001', ' Feb', ' 8th', ' Fri', '    ',
        ' 4PM', ' Sat', ' 8AM', ' 4PM', '11th',' 8AM', ' 4PM'
    end

    it "hourly - minmal interesting" do

      using_scale_adapter :Hourly

      at_times '2001-02-08T04:05:06+07:00',
               '2001-02-08T05:05:06+07:00',
               '2001-02-08T06:05:06+07:00',
               '2001-02-08T07:05:06+07:00',
               '2001-02-08T08:05:06+07:00'

      sparse_matrix [ 1, 2, 3, 4, 5 ], nil, [ 2, 2, 2, 2, 2 ]
      _go
      _expect_headers '2001', ' Feb', ' 8th', ' 7AM', ' 8AM'
    end

    def _go

      # ~ begin re-write a bidding process that always wins

      first_dt = @datetimes.fetch 0

      bucket_begin_dt = @cls._time_unit_adapter_.
        nearest_previous_bucket_begin_datetime_ first_dt

      _offset_rational = first_dt - bucket_begin_dt

      _distance_in_days_rational = @datetimes.fetch( -1 ) - first_dt

      _bucket_count = (
        ( _offset_rational + _distance_in_days_rational ) /
        @cls::DAYS_PER_BUCKET
      ).ceil

      # ~ end

      o = @cls.new bucket_begin_dt, _bucket_count

      o.column_A = __column_A
      o.column_A_max_width = __column_A_max_width

      o.column_B_rows = __build_column_B_rows
      o.glyph_mapper = __glyph_mapper

      @io = __build_IO_spy
      o.text_downstream = @io

      o.render
      NIL_
    end

    def __build_IO_spy

      TestSupport_::IO.spy :debug_IO, debug_IO, :do_debug, do_debug
    end

    memoize_ :__column_A_max_width do

      __column_A.last.length
    end

    memoize_ :__column_A do

      [ 'a.txt', '+b.dir', '  b.txt' ]
    end

    memoize_ :__glyph_mapper do

      Home_::Magnetics_::Glypher_via_Glyphs_and_Stats.start(
        nil, 'c', 'b', 'a' )
    end

    def using_scale_adapter sym
      @cls = __subject::Scale_Adapters_.const_get sym, false
      NIL_
    end

    def at_times * s_a
      _DT = Home_.lib_.date_time
      @datetimes = s_a.map do | s |
        _DT.parse s
      end
      NIL_
    end

    def __build_column_B_rows

      _Mock_Row = _Mock_Row_
      _Mock_Filechange = _Mock_Filechange_

      @sparse_matrix_inputs.map do | a |
        if a
          _a = a.each_with_index.map do | d, idx |
            if d

              _Mock_Filechange_.new(
                @datetimes.fetch( idx ),
                d )
            end
          end

          _Mock_Row_.new _a
        end
      end
    end

    def sparse_matrix * d_a_a
      @sparse_matrix_inputs = d_a_a
      NIL_
    end

    def __subject
      Home_::ScaleTime_
    end

    def _expect_headers * s_a

      st = Home_.lib_.basic::String.line_stream @io.string
      s_a_ = ::Array.new 4
      4.times do | d |
        s_a_[ d ] = st.gets
      end

      margin = 9

      s = "    "

      s_a.each_with_index do | exp_s, d |

        4.times do | d_ |
          s[ d_ ] = s_a_[  d_ ][ d + margin ]
        end
        exp_s == s or fail "expected #{ exp_s.inspect }, had #{ s.inspect } (at [#{ d }]))"
      end
    end
  end
end
