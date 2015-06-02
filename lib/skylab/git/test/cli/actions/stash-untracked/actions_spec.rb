require_relative 'test-support'

module Skylab::Git::TestSupport::CLI::SU

  describe "[gi] CLI actions gsu actions" do

    extend TS_

    describe "status" do

      it "when stashes dir not found - x" do
        prepare_empty_tmpdir
        common_action
        expect :nonstyled, ERR_I, /\bfailed to status stash(?:\(?es\)?)? #{
          }- couldn't find #{ stashes_relpath_rxs } in \. and the 4 dirs #{
           }above it\z/
        expect_invited_to :status
      end

      it "whan stathes dir found - o" do
        ensure_workdir_with_nearby_collection
        common_action
        last_popen3_command_string.should eql(
          "git ls-files --others --exclude-standard" )
        expect :nonstyled, OUT_I, 'derpus'
        expect :nonstyled, OUT_I, 'nerpus/herpus'
        expect_succeeded
      end

      def common_action
        with_popen3_out_as "derpus\nnerpus/herpus"
        invoke_from_workdir 'status'
      end
    end

    # ~ business support

    def prepare_empty_tmpdir
      gsu_tmpdir.prepare
      workdir_pn.prepare
    end

    def ensure_workdir_with_nearby_collection
      wd = workdir_pn
      _ = "#{ stashes_relpath }/"
      wd.touch_r _ ; nil
    end

    def stashes_relpath_rxs
      rxs stashes_relpath
    end
    def stashes_relpath
      GSU[]::CLI::Services__::Find_Nearest_Hub::RELPATH__
    end

    # ~ common CLI test-time support

    def expect_invited_to i
      _rxs = /\A(?:try|use) #{ rxs WAZZLE } #{ rxs i } -h for help\z/i
      expect :styled, ERR_I, _rxs
      expect_no_more_lines
      @result.should eql GSU[]::CLI::GENERAL_FAILURE_EXITSTATUS
    end

    def rxs x
      ::Regexp.escape x.to_s
    end

    describe "show" do

      it "by default does the --stat format" do
        with_this_stash
        a = get_base_argv
        a.push '-v', 'derp'
        invoke a
        expect ERR_I, /\A\(while showing stash.+\bhad stash path\b/
        _exp = <<-HERE.unindent
          flip.txt      | 2 ++
          flop/floop.tx | 4 ++++
          2 files changed, 6 insertions(+), 0 deletions(-)
        HERE
        str = contiguous_string_from_lines_on OUT_I
        str_ = expect_styled str
        str_.should eql _exp
        expect_succeeded
      end

      it "it can also do the --patch format" do
        with_this_stash
        a = get_base_argv
        a.push '-p', 'derp'
        invoke a
        _exp = <<-HERE.unindent
          --- /dev/null
          +++ b/flip.txt
          @@ -0,0 +1,2 @@
          +one 
          +two
          --- /dev/null
          +++ b/flop/floop.tx
          @@ -0,0 +1,4 @@
          +one two
          +trhee
          +foour
          +
        HERE
        str = contiguous_string_from_lines_on OUT_I
        _str = expect_styled str
        _str.should eql _exp
        expect_succeeded
      end

      def get_base_argv
        argv = [ 'show' ]
        argv << '-s' << gsu_tmpdir.join( 'stashes' ).to_s
        argv
      end

      -> do
        yes = true
        define_method :with_this_stash do
          if yes
            yes = false
            _with_this_stash
          end
        end
      end.call

      def _with_this_stash
        gsu_tmpdir.prepare
        gsu_tmpdir.patch(<<-HERE.unindent)
          --- /dev/null
          +++ b/stashes/derp/flip.txt
          @@ -0,0 +1,2 @@
          +one 
          +two
          diff --git a/flop/floop.tx b/flop/floop.tx
          --- /dev/null
          +++ b/stashes/derp/flop/floop.tx
          @@ -0,0 +1,4 @@
          +one two
          +trhee
          +foour
          +
        HERE
      end
    end

    describe "save" do

      def prepare
        (( td = gsu_tmpdir )).clear
        td.mkdir 'Stashes'
        td.touch_r %w(
          calc/lippy.txt
          calc/dippy/doopy.txt
          calc/dippy/floopy.txt )
        nil
      end

      it "which moves the untracked files to a stash dir" do
        prepare
        td = gsu_tmpdir
        with_popen3_out_as "lippy.txt\ndippy/doopy.txt\ndippy/floopy.txt"
        _from_here = td.join 'calc'
        cd _from_here do
          invoke 'save', '-n', 'foo'
        end

        _exp = <<-HERE.unindent
          # git ls-files --others --exclude-standard
          # mkdir -p ../Stashes/foo
          # mv lippy.txt ../Stashes/foo/lippy.txt
          # mkdir -p ../Stashes/foo/dippy
          # mv dippy/doopy.txt ../Stashes/foo/dippy/doopy.txt
          # mv dippy/floopy.txt ../Stashes/foo/dippy/floopy.txt
        HERE
        _act = contiguous_string_from_lines_on ERR_I
        _act.should eql _exp
        expect_succeeded
      end
    end

    describe "pop" do

      def prepare
        (( td = gsu_tmpdir )).prepare
        td.touch_r %w(
          stashes/dingle/one-dir/one-file.txt
          stashes/dingle/two-dir/three-dir/three-file.txt
          stashes/dingle/four-dir-never-see/fifth-dir-empty/
          stashes/dingle/two-file.txt
          stashes/beta/whatever.txt
          working-dir/ )
        nil
      end

      it "which moves the stashed files back" do
        prepare
        td = gsu_tmpdir
        work_pn = td.join 'working-dir'
        _stashes_abs_pn = td.join 'stashes'
        stashes_rel_pn = _stashes_abs_pn.relative_path_from work_pn
        a = [ 'pop' ]
        # a << '-v'  # #todo is borked
        a << '-s' << stashes_rel_pn.to_s
        a << 'dingle'
        cd work_pn.to_s do
          invoke a
        end
        omg_a = [ 'mkdir', 'mv', 'mkdir', 2, 'mv' ]
        str = contiguous_string_from_lines_on ERR_I
        omg str, omg_a
        _exp_s = <<-HERE.unindent
          ./one-dir
          ./one-dir/one-file.txt
          ./two-dir
          ./two-dir/three-dir
          ./two-dir/three-dir/three-file.txt
          ./two-file.txt
        HERE
        _act_s = `cd #{ work_pn } ; find . -mindepth 1`
        _act_s.should eql _exp_s
      end

      def omg str, omg_a

        _OMG_RX = /(?<=\A# )[^ ]+(?=[ ])/

        line_a = str.split "\n"

        begin
          s = omg_a.shift
          if s.respond_to? :ascii_only?
            d = 1
          else
            d = s
            s = omg_a.shift
          end
          d.times do
            line = line_a.shift or fail "expected one more line had none"
            md = _OMG_RX.match line
            md or fail "expected line to match /#{ _OMG_RX.source }/ - #{
              line.inspect }"
            _s = md[ 0 ]
            _s == s or fail "expected #{ _s.inspect } to match #{ s.inspect }"
          end
        end while omg_a.length.nonzero?
        if line_a.length.nonzero?
          fail "expected no more lines had : #{ line_a[ 0 ].inspect }"
        end
      end
    end
  end
end
