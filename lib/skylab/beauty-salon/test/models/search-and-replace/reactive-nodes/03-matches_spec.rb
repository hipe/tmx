require_relative '../../../test-support'

module Skylab::BeautySalon::TestSupport

  describe "[bs] S & R - reactive nodes - matches" do

    extend TS_
    use :models_search_and_replace_reactive_nodes

    it "matches - many matches on one line." do

      call_API( * common_args_, :matches )

      expect_neutral_event :grep_command_head
      expect_no_more_events

      st = @result
      m = st.gets
      m_ = st.gets
      m__ = st.gets
      st.gets.should be_nil

      m.line_number.should eql 1
      m_.line_number.should eql 3
      m__.line_number.should eql 3

      all = [ m, m_, m_ ]

      all.map( & :path ).uniq.length.should eql 1
      basename_( m.path ).should eql _THREE_LINES_FILE

      m.md[ 0 ].should eql 'WAZOOZLE'
      m_.md[ 0 ].should eql 'wazoozle'

      o = m.to_line_stream
      o.gets.should eql "it's time for WAZOOZLE, see\n"
      o.gets.should be_nil
      o_ = m_.to_line_stream

      _s_a = o_.to_a
      _s_a.should eql [ "when i say \"wazoozle\" i mean WaZOOzle!\n" ]

      m = m__.dup_with :do_highlight, true
      o = m.to_line_stream
      s = o.gets
      o.gets.should be_nil

      haha = Home_.lib_.brazen::CLI::Styling.parse_styles s

      haha.map( & :first ).should eql [ :string, :style, :string, :style, :string ]
    end

    it "matches when multiline" do

      call_API(
        :grep_rx, '[a-z_]+\(',
        :search, /[a-z_]+\([^)]*\)/,
        :dirs, my_fixture_file_( '01-multiline' ),
        :files, '*.txt',
        :preview,
        :matches,
        :grep,
        :matches )

      st = @result

      match = st.gets
      match_ = st.gets
      st.gets.should be_nil

      match.line_number.should eql 3
      match_.line_number.should eql 9

      st = match.to_line_stream  # regression - just get first line
      _line = st.gets
      _line.should eql " foo(\n"

      s = match.to_line_stream.to_a.join EMPTY_S_

      s_ = match_.to_line_stream.to_a.join EMPTY_S_

      "#{ s }#{ s_ }".should eql <<-O.gsub( /^[ ]{8}/, EMPTY_S_ )
         foo(
           bar
         ) # baz
        fizz(  # biff
          boffo
        )
      O
    end
  end
end
