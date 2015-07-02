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
      end
