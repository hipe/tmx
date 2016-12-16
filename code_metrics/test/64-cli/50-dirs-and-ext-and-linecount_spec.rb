require_relative '../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] CLI - dirs and ex and linecount" do

    # the number of pluses that will display is a function of these factors:
    #
    #   • the proportionality of their input (numerically)
    #
    #   • how many characters wide is available for the whole table
    #     (which should be controlled here)
    #
    #   • how wide the paths are (!)
    #
    # we don't normalize the paths per se: they can get wider or narrower
    # based on the installation directory of the sidesystem! this is #NASTY
    # but is out of scope at the moment, so #open [#015]

    TS_[ self ]
    use :CLI_expectations
    use :CLI
    use :CLI_classify_common_screen

    context "lc" do

      it "info" do  # :+#bad-test

        st = build_info_line_stream_
        st.gets.should match %r(\Agenerated `find` command\b)
        d = ::File::SEPARATOR.getbyte 0
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

        # the string matrix is a 2 dimensional array of strings
        # which are the (stipped) cels that make up the table.

        4 == sm.length or fail

        expect_absolute_path_ sm.fetch( 0 ).fetch( 0 )
        expect_integer_ sm.fetch( 0 ).fetch( 1 )
        expect_percent_ sm.fetch( 1 ).fetch( 2 )
        expect_percent_ sm.fetch( 2 ).fetch( 3 )

        expect_pluses_ sm, 0..2, 4, :high, :low, :low
      end

      it "summary" do

        _sm = string_matrix_

        _sm.fetch( 3 ).should eql(
          [ "Total: 3", "12", EMPTY_S_, EMPTY_S_, EMPTY_S_ ] )
      end

      memoize_output_lines_ do

        # (was [#006], [#007.A])

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

        expect_integer_ row1.fetch( 1 ), 2..2
        expect_integer_ row2.fetch( 1 ), 1..1

        expect_percent_ row1.fetch( 2 )
        expect_percent_ row2.fetch( 3 )

        expect_pluses_ sm, 0..1, 4, :high, :low
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

        column[ 0 ].should eql [
          "fixture-files-one", "fixture-files-two", "Total: 2" ]

        column[ 1 ].should eql %w( 3 2 5 )

        column[ 2 ].should eql %w( 12 3 15 )

        expect_percent_ sm[ 0 ][ 3 ], 80.0
        expect_percent_ sm[ 1 ][ 4 ], 25.0

        expect_pluses_ sm, 0..1, 5, :high, :low
      end
    end
  end
end
