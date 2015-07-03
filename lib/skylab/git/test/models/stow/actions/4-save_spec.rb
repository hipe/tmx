require_relative '../../../test-support'

module Skylab::Git::TestSupport

  describe "[gi] models - stow - actions - save", wip: true do

    extend TS_
    use :models_stow_support

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
end
