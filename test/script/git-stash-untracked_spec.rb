load File.expand_path('../../../script/git-stash-untracked', __FILE__)

require File.expand_path('../../support', __FILE__)

module ::Skylab::GitStashUntracked::Tests
  include ::Skylab
  TestSupport = ::Skylab::TestSupport
  TMPDIR = TestSupport.tempdir('tmp/gsu', 1)
  describe ::Skylab::GitStashUntracked do
    describe "has an action called" do
      def stub_popen3 str
        me = self
        Open3.stub(:popen3) do |cmd, block|
          me.cmd_spy.replace cmd
          serr = TestSupport::MyStringIo.new('')
          sout = TestSupport::MyStringIo.new(str)
          block.call(nil, sout, serr)
        end
      end
      let :app do
        stderr = self.stderr
        GitStashUntracked::Porcelain.new { on_all { |e| stderr.puts e } }
      end
      let :cmd_spy do '' end
      let :runtime_stub do
        o = Object.new
        o.stub(:emit) { |a, b| stderr.puts b.to_s }
        o
      end
      let :stderr do
        TestSupport::MyStringIo.new
      end
      describe "status" do
        it "which lists untracked files" do
          stub_popen3("derpus\nnerpus/herpus")
          app.invoke %w(status)
          cmd_spy.should eql("git ls-files -o --exclude-standard")
          stderr.to_s.should match(/nerpus\/herpus/)
        end
      end
      describe "save" do
        it "which moves the untracked files to a stash dir" do
          TMPDIR.prepare
          stub_popen3("lippy\ndippy/doopy\ndippy/floopy")
          app.invoke ['save', 'foo', '-n', '-s', TMPDIR.to_s]
          str = <<-HERE.unindent
            # git ls-files -o --exclude-standard
            mkdir -p tmp/gsu/foo
            mv lippy tmp/gsu/foo/lippy
            mkdir -p tmp/gsu/foo/dippy
            mv dippy/doopy tmp/gsu/foo/dippy/doopy
            mv dippy/floopy tmp/gsu/foo/dippy/floopy
          HERE
          stderr.to_s.should eql(str)
        end
      end
      describe "list" do
        it "which lists the known stashes (just a basic directory listing)" do
          TMPDIR.prepare.touch_r %w(
            stashes/alpha/herpus/derpus.txt
            stashes/alpha/flerpus/nerpus.txt
            stashes/alpha/empty_dir/
            stashes/beta/whatever.txt
          )
          GitStashUntracked::Plumbing::List.new(runtime_stub, :stashes => TMPDIR.join('stashes')).invoke.should_not eql(false)
          target = <<-HERE.unindent
            alpha
            beta
          HERE
          stderr.to_s.should eql(target)
          stderr.truncate(0) ; stderr.rewind
          app.invoke ['list', '-s', "#{TMPDIR}/stashes"] # same thing but invoked though the porcelain
          stderr.to_s.should eql(target)
        end
      end
      describe "pop" do
        it "which moves the stashed files back"
      end
    end
  end
end

