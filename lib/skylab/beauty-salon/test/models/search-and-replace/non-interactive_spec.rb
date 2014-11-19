require_relative 'test-support'

module Skylab::BeautySalon::TestSupport::Models::Search_and_Replace

  describe "[bs] S & R - the non-interactive API" do

    BS_._lib.brazen.test_support::Expect_Event[ self ]

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

      expect_neutral_event :command_string
      expect_no_more_events
      basename( @result.gets ).should eql 'one-line.txt'
      basename( @result.gets ).should eql THREE_LINES_FILE_
      @result.gets.should be_nil
    end

    it "same but only those with matching content - note syntax isomorphs interactive" do

      call_API( * same, :files )

      expect_neutral_event :grep_command_head

      scan = @result
      x = scan.gets
      scan.gets.should be_nil
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

    it "matches" do
      call_API( * same, :matches )
      expect_neutral_event :grep_command_head
      expect_no_more_events
      x = @result.gets
      x_ = @result.gets
      @result.gets.should be_nil
      x.line_number.should eql 1
      x_.line_number.should eql 3
      x.path.should eql x_.path
      basename( x.path ).should eql THREE_LINES_FILE_
      x.md[ 0 ].should eql 'WAZOOZLE'
      x_.md[ 0 ].should eql 'wazoozle'
      x.line.should match %r(\Ait's time )
      x_.line.should match %r(\Awhen i say )
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
