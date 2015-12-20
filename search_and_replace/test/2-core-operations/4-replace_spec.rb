require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[se] S & R - reactive nodes - replace", wip: true do

    TS_[ self ]
    use :operations

    it "REPLACE!" do

      start_tmpdir_
      to_tmpdir_add_wazoozle_file_

      call_API(
        :search, /\bHAHA\b/,
        :dirs, @tmpdir.to_path,
        :replace, 'GOOD JERB',
        :files, '*',
        :preview,
        :matches,
        :grep,
        :replace,
      )

      st = @result

      count = 0
      while _match = st.gets
        count += 1
      end

      expect_neutral_event :grep_command_head

      _em = expect_OK_event_ :changed_file,

        %r(\Areplace node changed file - .+ok-whatever-wazoozle\.txt)

      expect_no_more_events

      _ev = _em.cached_event_value

      ::File.read( _ev.path ).should eql(
        "ok oh my geez --> GOOD JERB <--\n" )
    end
  end
end
