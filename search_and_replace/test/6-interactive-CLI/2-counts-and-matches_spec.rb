require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] interactive CLI integration - counts", wip: true do

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
        ps = Home_.lib_.brazen::CLI_Support::Styling::Parse_styles

        a = [ "h#{}inkenlooper" ]
        a.push a.last.upcase
        see = ::Hash[ a.each_with_index.map { |*a_| a_ } ]

        head_rx = /\A[^:]+:\d+:.+/

        _a.each do |line|

          x = ps[ line ]

          :string == x.first.first or fail
          :style == x[1].first or fail

          _head = x.first.last
          _match = x[2].last

          head_rx =~ _head or fail
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
