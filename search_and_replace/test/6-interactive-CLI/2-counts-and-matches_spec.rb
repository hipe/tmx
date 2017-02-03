require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] interactive CLI integration - counts" do

    TS_[ self ]
    use :my_interactive_CLI

    context "counts" do

      given do
        input(
          'r', hinkenloooper_regexp_string_,
          'p', this_test_directory_,
          'sea',
          'counts',
        )
      end

      it "item lines look good" do

        a = _lines
        rx = %r(#{ ::Regexp.escape ::File::SEPARATOR }\d-[a-z0-9-]+_spec\.rb - [12] matching lines?\z)
        2.times do |d|
          a.fetch( d ) =~ rx or fail
        end
      end

      it "there is a summary line" do

        _lines.last == "(3 matching lines in 2 paths)" or fail
      end

      it "there are 2 item lines" do

        _lines.length == 3 or fail
      end

      shared_subject :_lines do

        st = screen.to_content_line_stream_on :serr
        st.gets ; st.gets  # #open [#006]
        a = []
        begin
          s = st.gets
          s.length.zero? and break
          a.push s
          redo
        end while nil
        a
      end

      it "ends with buttons of the correct frame" do
        is_on_frame_number_with_buttons_ 2
      end
    end

    context "matches" do

      given do
        input(
          'r', hinkenloooper_regexp_string_,
          'p', this_test_directory_,
          'sea',
          'ma',
        )
      end

      it "write *styled* lines to STDERR (not stdout b.c styled..) (#FRAGILE-TEST)" do

        st = screen.to_content_line_stream_on :serr

        # while #open [#004]:
        st.gets  # find command EEW
        st.gets  # grep command EEW

        # #eyeblood: make sure that the next three lines have both variants

        _a = [ st.gets, st.gets, st.gets ]

        a = [ "h#{}inkenlooper" ]
        a.push a.last.upcase
        see = ::Hash[ a.each_with_index.map { |*a_| a_ } ]

        head_rx = /\A[^:]+:\d+:.+/

        lib = Home_.lib_.zerk::CLI::Styling
        _a.each do |line|

          chunk_st = lib::ChunkStream_via_String[ line ]
          head_s = chunk_st.gets
          head_s.length.zero? && fail

          chunk = chunk_st.gets
          _match = chunk.string

          _chunk_ = chunk_st.gets
          _chunk_ || fail

          _chunk_ = chunk_st.gets
          _chunk_ && fail

          head_rx =~ head_s or fail
          a[ see.fetch( _match ) ] = nil
        end

        a.compact!
        a.length.zero? or fail
      end

      it "ends with buttons of the correct frame" do
        is_on_frame_number_with_buttons_ 2
      end
    end
  end
end
