require_relative '../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] CLI - dirs and ext and linecount" do

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
        expect( st.gets ).to match %r(\Agenerated `find` command\b)
        d = ::File::SEPARATOR.getbyte 0
        path = -> do
          s = st.gets
          d == s.getbyte( 0 ) or fail "expected absolute path: #{ s.inspect }"
        end
        path[]
        path[]
        path[]
        expect( st.gets ).to eql "(including blank lines and comment lines)\n"
        expect( st.gets ).to match %r(\bwc -l \/)
        expect( st.gets ).to be_nil
      end

      it "headers" do
        expect( headers_ ).to eql(
         [ :file, :lines, :total_share, :normal_share, :_blank_header_ ] )
      end

      it "body" do

        sm = string_matrix_

        # the string matrix is a 2 dimensional array of strings
        # which are the (stipped) cels that make up the table.

        4 == sm.length or fail

        want_absolute_path_ sm.fetch( 0 ).fetch( 0 )
        want_integer_ sm.fetch( 0 ).fetch( 1 )
        want_percent_ sm.fetch( 1 ).fetch( 2 )
        want_percent_ sm.fetch( 2 ).fetch( 3 )

        want_pluses_ sm, 0..2, 4, :high, :low, :low
      end

      it "summary" do

        _sm = string_matrix_

        expect( _sm.fetch 3 ).to eql(
          [ "Total: 3", "12", EMPTY_S_, EMPTY_S_, EMPTY_S_ ] )
      end

      memoize_output_lines_ do

        # (was [#006], [#007.A])
        invoke(
          'line-count', Fixture_file_directory_[], '-vvv',
          PATH_MAX_WIDTH: 68  # arrived at practically, based on fixture tree
        )
      end
    end

    context "ext" do

      it "info" do

        st = build_info_line_stream_
        expect( st.gets ).to eql "(verbosity level three is highest (had four).)\n"
        expect( st.gets ).to match %r(\Agenerated `find` command\b)
        expect( st.gets ).to be_nil
      end

      it "headers" do

        expect( headers_ ).to eql(
          [ :extension, :num_files, :total_share, :normal_share, :_blank_header_ ] )
      end

      it "body" do

        sm = string_matrix_

        3 == sm.length or fail

        row1 = sm.fetch 0
        row2 = sm.fetch 1

        expect( row1.fetch 0 ).to eql '*.code'
        expect( row2.fetch 0 ).to eql '*.file'

        want_integer_ row1.fetch( 1 ), 2..2
        want_integer_ row2.fetch( 1 ), 1..1

        want_percent_ row1.fetch( 2 )
        want_percent_ row2.fetch( 3 )

        want_pluses_ sm, 0..1, 4, :high, :low
      end

      it "summary" do

        _sm = string_matrix_

        expect( _sm.last ).to eql [ "Total: 2", "3", EMPTY_S_, EMPTY_S_, EMPTY_S_ ]
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

        expect( headers_ ).to eql(
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

        expect( column[ 0 ] ).to eql [
          "fixture-files-one", "fixture-files-two", "Total: 2" ]

        expect( column[ 1 ] ).to eql %w( 3 2 5 )

        expect( column[ 2 ] ).to eql %w( 12 3 15 )

        want_percent_ sm[ 0 ][ 3 ], 80.0
        want_percent_ sm[ 1 ][ 4 ], 25.0

        want_pluses_ sm, 0..1, 5, :high, :low
      end
    end
  end
end
