require_relative '../../../test-support'

module Skylab::Git::TestSupport

  describe "[gi] models - stow - actions - mutators", wip: true do

    extend TS_
    use :models_stow_support

    # ~ common CLI test-time support

    def rxs x
      ::Regexp.escape x.to_s
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
