require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] core operations - matches" do

    TS_[ self ]
    use :my_API

    context "(normal)" do

      call_by do

        _state = call(
          :ruby_regexp, /\b(with one line|wazoozle)\b/i,
          :path, common_haystack_directory_,
          :filename_patterns, EMPTY_A_,
          :search,
          :matches,
        )

        _statistify _state
      end

      it "matches exist across two files" do

        bx = _matches_box
        bx.has_key _ONE_LINE_FILE or fail
        bx.has_key _THREE_LINES_FILE or fail
      end

      it "each match knows its (starting) line number (starts at one)" do
        expect( _match.lineno ).to eql 1
      end

      it "each match knows its own path" do
        expect( basename_( _match.path ) ).to eql _ONE_LINE_FILE
      end

      it "each match has a platform matchdata" do

        a = _matches
        expect( a.fetch( 0 ).md[ 0 ] ).to eql 'WAZOOZLE'
        expect( a.fetch( 1 ).md[ 1 ] ).to eql 'wazoozle'
      end

      it "each match (because it might be multiline) can `to_line_stream`" do

        _ = _matches.fetch 0
        st = _.to_line_stream
        expect( st.gets ).to eql "it's time for WAZOOZLE, see\n"
        expect( st.gets ).to be_nil
      end

      it "multiple matches on one line will each reflect that same line" do

        lines1, lines2 = _lines_1_lines_2
        expect( lines1 ).to eql lines2
      end

      it "(but with each `to_line_stream` new lines are made (strscan))" do

        lines1, lines2 = _lines_1_lines_2
        lines1.fetch( 0 ).object_id == lines2.fetch( 0 ).object_id and fail
      end

      shared_subject :_lines_1_lines_2 do

        a = _matches
        m1 = a.fetch 1
        m2 = a.fetch 2

        st1 = m1.to_line_stream
        st2 = m2.to_line_stream

        sa1 = st1.to_a
        sa2 = st2.to_a
        [ sa1, sa2 ]
      end

      it "if highlighting is turned on, you can see where the match is" do

        _read_only_match = _matches.fetch 2

        _expag = Home_::CLI.highlighting_expression_agent_instance__
        _st = _read_only_match.to_line_stream_under _expag

        lines = _st.to_a
        1 == lines.length or fail

        st = Home_.lib_.zerk::CLI::Styling::ChunkStream_via_String[ lines[0] ]

        st.gets.length.nonzero? || fail  # there is some leading, non-styled string

        chunk_1 = st.gets
        chunk_2 = st.gets
        st.gets && fail  # there is only one chunk
        chunk_1.styles == [:strong, :green] || fail
        chunk_2.styles == [:no_style] || fail
        chunk_1.string == "WaZOOzle" || fail
        chunk_2.string == "!\n" || fail
      end

      shared_subject :_match do
        _matches_box.h_.fetch( _ONE_LINE_FILE ).matches.fetch 0
      end

      shared_subject :_matches do
        _matches_box.h_.fetch( _THREE_LINES_FILE ).matches
      end
    end

    # it "matches when multiline" do

    context "(multiline)" do

      call_by do

        _path = my_fixture_tree_ '1-multiline'

        _state = call(
          :egrep_pattern, '[a-z_]+\(',
          :ruby_regexp, /[a-z_]+\([^)]*\)/,
          :path, _path,
          :filename_pattern, '*.txt',
          :search,
          :matches,
        )

        _statistify _state
      end

      _FILE = 'file-1.txt'

      it "2 matches in one file" do
        expect( _matches_box.a_ ).to eql [ _FILE ]
      end

      it "2 matches, one on lines 3 and one on 9" do

        a = _matches
        expect( a.length ).to eql 2
        expect( a.fetch( 0 ).lineno ).to eql 3
        expect( a.fetch( 1 ).lineno ).to eql 9
      end

      it "the first match has multiple lines" do

        _match = _matches.fetch 0

        _st = _match.to_line_stream

        want_these_lines_in_array_ _st do |y|
          y << " foo(\n"
          y << "   bar\n"
          y << " ) # baz\n"
        end
      end

      it "the second match has the other multiple lines" do

        _match = _matches.fetch 1

        _act = _match.to_line_stream.to_a.join EMPTY_S_

        _exp = <<-HERE.gsub( %r(^[ ]{10}), EMPTY_S_ )
          fizz(  # biff
            boffo
          )
        HERE

        expect( _act ).to eql _exp
      end

      dangerous_memoize :_matches do
        _matches_box.fetch( _FILE ).matches
      end
    end

    def _matches_box
      root_ACS_customized_result
    end

    def _statistify state

      st = state.result

      _Per_File = ___Per_File

      matchbox = Common_::Box.new

      for_ = -> path do

        matchbox.touch basename_ path do
          _Per_File.new
        end
      end

      while ma = st.gets

        for_[ ma.path ].add_match ma
      end

      state.to_state_with_customized_result matchbox
    end

    dangerous_memoize :___Per_File do

      class Struct_2_3

        def initialize
          @matches = []
        end

        def add_match ma
          @matches.push ma ; nil
        end

        attr_reader(
          :matches,
        )

        self
      end
    end
  end
end
