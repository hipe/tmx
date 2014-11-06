require_relative 'test-support'

module Skylab::BeautySalon::TestSupport::Models::Search_and_Replace

  describe "[bs] search and replace" do

    extend TS_

    context "counts" do

      _LAST_ITEM_RX = %r(\A[ ]+files[ ])

      it "testing interactivity is fragile but possible" do

        start_session existent_tmpdir_path

        @session.expect_line_eventually _LAST_ITEM_RX
        @session.puts 'search'
        @session.puts '\bhinkenlooper\b'
        @session.puts 'dir'
        @session.puts TS_.dir_pathname.to_path
        @session.puts 'file'
        @session.puts '*.rb'
        @session.expect_line_eventually _LAST_ITEM_RX

        @session.puts 'preview'
        @session.expect_line_eventually %r(\A[ ]+matches[ ])

        @session.puts 'matches'
        @session.expect_line_eventually %r(\A[ ]+ruby[ ])

        @session.puts 'grep'
        @session.expect_line_eventually %r(\A[ ]+replace[ ])

        @session.gets.should eql "\n"

        @session.puts 'counts'

        line = @session.gets
        line.should match %r(\bgrep -E\b)

        line = @session.gets
        line.chop!

        totals = @session.gets
        totals.chop!

        # hinkenlooper
        # hinkenlooper

        totals.should eql '(2 matches in 1 file)'

        expect_line = "#{ ::File.expand_path( __FILE__ ) }:2"

        line.should eql expect_line

        @session.close

      end
    end
  end
end
