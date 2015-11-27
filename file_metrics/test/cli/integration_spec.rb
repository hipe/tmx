require_relative '../test-support'

module Skylab::FileMetrics::TestSupport

  describe "[fm] CLI - integration" do

    TS_[ self ]
    use :CLI
    use :CLI_expectations
    use :CLI_classify_common_screen

    context "lc" do

      it "info" do  # :+#bad-test

        st = build_info_line_stream_
        st.gets.should match %r(\Agenerated `find` command\b)
        d = '/'.getbyte 0
        path = -> do
          s = st.gets
          d == s.getbyte( 0 ) or fail "expected absolute path: #{ s.inspect }"
        end
        path[]
        path[]
        path[]
        st.gets.should eql "(including blank lines and comment lines)\n"
        st.gets.should match %r(\Awc -l \/)
        st.gets.should be_nil
      end

      it "headers" do

        headers_.should eql(
         [ :file, :lines, :total_share, :normal_share, :_blank_header_ ] )
      end

      it "body" do

        sm = string_matrix_

        4 == sm.length or fail

        _expect_absolute_path sm.fetch( 0 ).fetch( 0 )
        _expect_integer sm.fetch( 0 ).fetch( 1 )
        _expect_percent sm.fetch( 1 ).fetch( 2 )
        _expect_percent sm.fetch( 2 ).fetch( 3 )
        _expect_pluses sm.fetch( 2 ).fetch( 4 ), 11..11
      end

      it "summary" do

        _sm = string_matrix_

        _sm.fetch( 3 ).should eql(
          [ "Total: 3", "12", EMPTY_S_, EMPTY_S_, EMPTY_S_ ] )
      end

      memoize_output_lines_ do

        # (was [#006], [#007])

        invoke 'line-count', Fixture_file_directory_[], '-vvv'
      end
    end

    context "ext" do

      it "info" do

        st = build_info_line_stream_
        st.gets.should eql "(verbosity level three is highest (had four).)\n"
        st.gets.should match %r(\Agenerated `find` command\b)
        st.gets.should be_nil
      end

      it "headers" do

        headers_.should eql(
          [ :extension, :num_files, :total_share, :normal_share, :_blank_header_ ] )
      end

      it "body" do

        sm = string_matrix_

        3 == sm.length or fail

        row1 = sm.fetch 0
        row2 = sm.fetch 1

        row1.fetch( 0 ).should eql '*.code'
        row2.fetch( 0 ).should eql '*.file'

        _expect_integer row1.fetch( 1 ), 2..2
        _expect_integer row2.fetch( 1 ), 1..1

        _expect_percent row1.fetch( 2 )
        _expect_percent row2.fetch( 3 )

        _expect_pluses row2.fetch( 4 )
      end

      it "summary" do

        _sm = string_matrix_

        _sm.last.should eql [ "Total: 2", "3", EMPTY_S_, EMPTY_S_, EMPTY_S_ ]
      end

      memoize_output_lines_ do

        invoke 'ext', Fixture_file_directory_[], '-vvvv'
      end
    end

    context "dirs" do

      memoize_output_lines_ do

        invoke 'dirs', Fixture_tree_directory_[]  # intentionally without verbose

      end

      it "info" do

        st = build_info_line_stream_
        s = st.gets
        if s
          fail "expected no info lines (because no verbose flag), had: #{ s.inspect }"
        end
      end

      it "header" do

        headers_.should eql(
          [ :directory, :num_files, :num_lines, :total_share, :normal_share, :_blank_header_ ] )
      end

      it "body & summary" do

        sm = string_matrix_

        len = 3

        len == sm.length or fail

        column = -> d do

          len.times.map do | d_ |
            sm.fetch( d_ ).fetch( d ).strip
          end
        end

        column[ 0 ].should eql %w(
          fixture-files-one fixture-files-two Total: )

        column[ 1 ].should eql %w( 3 2 5 )

        column[ 2 ].should eql %w( 12 3 15 )

        _expect_percent sm[ 0 ][ 3 ], 80.0
        _expect_percent sm[ 1 ][ 4 ], 25.0

        _expect_pluses sm[ 1 ][ 5 ]
      end
    end
  end
end
