require_relative 'test-support'

module Skylab::BeautySalon::TestSupport::Models::Search_and_Replace

  describe "[bs] S & R - the non-interactive API" do

    TestLib_::Expect_event[ self ]

    extend TS_

    it "ping-esque" do
      call_API :ziffo
      expect_not_OK_event :child_not_found
      expect_failed
    end

    it "stream of first-pass search-space of files (`find`)" do

      call_API :dirs, TestSupport_::Data.dir_pathname.to_path,
        :files, '*-line*.txt',
        :preview,
        :files

      expect_neutral_event :find_command_args
      expect_no_more_events
      basename( @result.gets ).should eql 'one-line.txt'
      basename( @result.gets ).should eql THREE_LINES_FILE_
      @result.gets.should be_nil
    end

    it "same but only those with matching content - note syntax isomorphs interactive" do

      call_API( * same, :files )

      expect_neutral_event :grep_command_head

      stream = @result
      x = stream.gets
      stream.gets.should be_nil
      basename( x ).should eql THREE_LINES_FILE_
    end

    it "counts" do
      i_a = []

      @result = _API.call( * same,
        :counts,
        :on_event_selectively,
        -> * i_a_, & ev_p do
          i_a.push i_a_.last
          nil
        end )

      i_a.should eql [ :grep_command_head ]

      x = @result.gets
      @result.gets.should be_nil
      x.count.should eql 2
      basename( x.path ).should eql THREE_LINES_FILE_
    end

    it "matches - many matches on one line." do

      call_API( * same, :matches )

      expect_neutral_event :grep_command_head
      expect_no_more_events

      m = @result.gets
      m_ = @result.gets
      m__ = @result.gets
      @result.gets.should be_nil

      m.line_number.should eql 1
      m_.line_number.should eql 3
      m__.line_number.should eql 3

      all = [ m, m_, m_ ]

      all.map( & :path ).uniq.length.should eql 1
      basename( m.path ).should eql THREE_LINES_FILE_

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
        :dirs, TS_::Fixtures.dir_pathname.join( '01-multiline' ).to_path,
        :files, '*.txt',
        :preview,
        :matches,
        :grep,
        :matches )

      match = @result.gets
      match_ = @result.gets
      @result.gets.should be_nil

      match.line_number.should eql 3
      match_.line_number.should eql 9

      st = match.to_line_stream  # regression - just get first line
      _line = st.gets
      _line.should eql " foo(\n"

      s = match.to_line_stream.to_a.join Home_::EMPTY_S_
      s_ = match_.to_line_stream.to_a.join Home_::EMPTY_S_
      "#{ s }#{ s_ }".should eql <<-O.gsub( /^[ ]{8}/, Home_::EMPTY_S_ )
         foo(
           bar
         ) # baz
        fizz(  # biff
          boffo
        )
      O
    end

    it "REPLACE!" do
      start_tmpdir
      to_tmpdir_add_wazoozle_file

      call_API(
        :search, /\bHAHA\b/,
        :dirs, @tmpdir.to_path,
        :replace, 'GOOD JERB',
        :files, '*',
        :preview,
        :matches,
        :grep,
        :replace )

      expect_neutral_event :grep_command_head

      count = 0
      while _match = @result.gets
        count += 1
      end

      ev = expect_OK_event :changed_file,
        %r(\Areplace node changed file - .+ok-whatever-wazoozle\.txt)

      expect_no_more_events

      ::File.read( ev.path ).should eql "ok oh my geez --> GOOD JERB <--\n"
    end

    def same
      [ :search, /\bwazoozle\b/i,
        :dirs, TestSupport_::Data.dir_pathname.to_path,
        :files, '*-line*.txt',
        :preview,
        :matches,
        :grep ]
    end

    def basename s
      s[ s.rindex( SLASH_ ) + 1 .. -1 ]
    end
  end
end
