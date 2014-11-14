require_relative 'test-support'

module Skylab::BeautySalon::TestSupport::Models::Search_and_Replace

  describe "[bs] search and replace" do

    extend TS_

    context "counts" do

      _LAST_ITEM_RX = %r(\A[ ]+files[ ])

      it "testing interactivity is possble but cumbersome" do

        start_session existent_tmpdir_path
        o = @session
        o.expect_line_eventually _LAST_ITEM_RX

        o.puts 'search'
        o.puts '\bhinkenlooper\b'

        o.puts 'dirs'
        o.puts TS_.dir_pathname.to_path
        o.expect_line_eventually _LAST_ITEM_RX

        o.puts 'files'
        o.puts '*.rb'
        o.expect_line_eventually _LAST_ITEM_RX

        o.puts 'preview'
        o.expect_line_eventually %r(\A[ ]+matches[ ])

        o.puts 'matches'
        o.expect_line_eventually %r(\A[ ]+ruby[ ])

        o.puts 'grep'
        o.expect_line_eventually %r(\A[ ]+grep[ ]+ON\b)
        o.expect_line_eventually %r(\A[ ]+matches[ ])

        o.gets.should eql "\n"

        o.puts 'counts'

        line = o.gets
        line.should match %r(\bgrep -E\b)

        line = o.gets
        line.chop!

        totals = o.gets
        totals.chop!

        # hinkenlooper
        # hinkenlooper

        totals.should eql '(2 matches in 1 file)'

        expect_line = "#{ ::File.expand_path( __FILE__ ) }:2"

        line.should eql expect_line

        o.close

      end
    end
  end
end
