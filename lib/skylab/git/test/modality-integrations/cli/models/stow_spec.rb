      # wip: true

      if false

      # expect ERR_I, /\A\(while listing stash.+no stashes found in /

      def get_common_argv
        [ 'list', '-s', "#{ gsu_tmpdir }/stashiz" ]
      end

      it "list the known stashes (CLI)" do
        prepare
        invoke get_common_argv
        _act_s = contiguous_string_from_lines_on OUT_I
        _act_s.should eql exp_s
        expect_succeeded
      end

      it "status when stashes dir not found - x" do
        prepare_empty_tmpdir
        common_action
        expect :nonstyled, ERR_I, /\bfailed to status stash(?:\(?es\)?)? #{
          }- couldn't find #{ stashes_relpath_rxs } in \. and the 4 dirs #{
           }above it\z/
        expect_invited_to :status
      end

      def expect_invited_to i
        _rxs = /\A(?:try|use) #{ rxs WAZZLE } #{ rxs i } -h for help\z/i
        expect :styled, ERR_I, _rxs
        expect_no_more_lines
        @result.should eql GSU[]::CLI::GENERAL_FAILURE_EXITSTATUS
      end

      end
