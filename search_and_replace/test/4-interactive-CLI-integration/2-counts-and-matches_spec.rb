require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] modality integrations - 1. fbf, fbg, counts" do

    TS_[ self ]
    use :expect_screens
    use :interactive_CLI

    context "counts" do

      given do
        input(
          'r', hinkenloooper_regexp_string_,
          'p', this_directory_that_exists_,
          'sea',
          'counts',
        )
      end

      it "looks YAML-y (for now)" do

        _st = screen.to_content_line_stream_on :sout

        _act = _st.reduce_into_by "" do | m, x |
          m << "#{ x }#{ NEWLINE_ }"
        end

        _rx_s = <<-HERE.gsub!( /^[ ]{10}/, EMPTY_S_ )
           path: .+_spec\\.rb
          count: [12]
          ---
           path: .+_spec\\.rb
          count: [12]
        HERE

        _rx = ::Regexp.new _rx_s

        _act.should match _rx
      end

      it "ends with buttons of the correct frame" do
        is_on_frame_number_with_buttons_ 2
      end
    end

    context "matches" do

      given do
        input(
          'r', hinkenloooper_regexp_string_,
          'p', this_directory_that_exists_,
          'sea',
          'ma',
        )
      end

      it "write *styled* lines to STDERR (not stdout b.c styled..) (#FRAGILE-TEST)" do

        st = screen.to_content_line_stream_on :serr
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
