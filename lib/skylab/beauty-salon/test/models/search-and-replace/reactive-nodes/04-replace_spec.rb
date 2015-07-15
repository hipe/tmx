require_relative '../../../test-support'

module Skylab::BeautySalon::TestSupport

  describe "[bs] S & R - reactive nodes - replace" do

    extend TS_
    use :models_search_and_replace_reactive_nodes

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

      expect_neutral_event :grep_command_head

      st = @result

      count = 0
      while _match = st.gets
        count += 1
      end

      ev = expect_OK_event :changed_file,
        %r(\Areplace node changed file - .+ok-whatever-wazoozle\.txt)

      expect_no_more_events

      ::File.read( ev.path ).should eql "ok oh my geez --> GOOD JERB <--\n"
    end
  end
end
