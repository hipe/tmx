load File.expand_path('../../../../../script/git-stash-untracked', __FILE__)

require File.expand_path('../../../test-support/core', __FILE__)

require_relative '../../test-support/tmpdir'


module ::Skylab::GitStashUntracked::Tests
  include ::Skylab

  TestSupport = ::Skylab::TestSupport

  tdpn = ::Skylab::TMPDIR_PATHNAME.join 'gsu-xyzzy'

  gsu_tmpdir = TestSupport.tmpdir tdpn.to_s, 1

  describe ::Skylab::GitStashUntracked do

    describe "has an action called" do

      let :app do
        GitStashUntracked::Porcelain.new do |o|
          o.on_all do |e|
            if debug
              debug.puts "    (dbg:#{ [e.type, e.message].inspect })"
            end
            stderr.puts e
          end
        end
      end

      def cd path, block
        ::FileUtils.cd path.to_s, &block
      end

      attr_accessor :cmd_spy

      attr_accessor :debug

      def debug!
        self.debug =  $stderr
        nil
      end

      let :runtime_stub do
        o = ::Object.new
        o.stub :emit do |type, payload|
          debug and debug.puts("    (dbg: #{ [type, payload].inspect })")
          stderr.puts payload.to_s
        end
        o
      end

      let :stderr do
        ::StringIO.new
      end

      def with_popen3_out_as str
        me = self
        ::Open3.stub :popen3 do |cmd, &block|
          self.cmd_spy = cmd
          serr = ::StringIO.new ''
          sout = ::StringIO.new str
          block[ nil, sout, serr ]
        end
      end



      # -- * --


      describe "status" do
        it "which lists untracked files" do
          with_popen3_out_as "derpus\nnerpus/herpus"
          app.invoke %w(status)
          cmd_spy.should eql("git ls-files -o --exclude-standard")
          stderr.string.should match(/nerpus\/herpus/)
        end
      end



      describe "save" do
        it "which moves the untracked files to a stash dir" do
          gsu_tmpdir.prepare
          with_popen3_out_as "lippy\ndippy/doopy\ndippy/floopy"
          from_here = gsu_tmpdir.dirname.dirname # foo when foo/tmp/gsu-xyzzy
          cd from_here, -> _ do
            app.invoke ['save', 'foo', '-n', '-s', gsu_tmpdir.to_s]
          end

          actual = stderr.string

          expected = <<-HERE.unindent
            # git ls-files -o --exclude-standard
            mkdir -p ./tmp/gsu-xyzzy/foo/lippy
            mv lippy ./tmp/gsu-xyzzy/foo/lippy
            mkdir -p ./tmp/gsu-xyzzy/foo/dippy/doopy
            mv dippy/doopy ./tmp/gsu-xyzzy/foo/dippy/doopy
            mv dippy/floopy ./tmp/gsu-xyzzy/foo/dippy/floopy
          HERE

          actual.should eql(expected)
        end
      end



      describe "list" do
        it "which lists the known stashes (just a basic directory listing)" do
          gsu_tmpdir.prepare.touch_r %w(
            stashes/alpha/herpus/derpus.txt
            stashes/beta/whatever.txt
          )
          GitStashUntracked::Plumbing::List.new(runtime_stub, :stashes => gsu_tmpdir.join('stashes')).invoke.should_not eql(false)
          expected = <<-HERE.unindent
            alpha
            beta
          HERE
          stderr.string.should eql(expected)
          stderr.truncate(0) ; stderr.rewind
          app.invoke ['list', '-s', "#{gsu_tmpdir}/stashes"] # same thing but invoked though the porcelain
          stderr.string.should eql(expected)
        end
      end


      describe "show" do

        define_method :with_this_stash do
          gsu_tmpdir.prepare.patch(<<-HERE.unindent)
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

        include ::Skylab::Porcelain::Styles # unstylize

        it "by default does the --stat format" do
          with_this_stash
          app.invoke %w(show derp -s).push(gsu_tmpdir.join('stashes').to_s)
          expected = <<-HERE.unindent
            flip.txt      | 2 ++
            flop/floop.tx | 4 ++++
            2 files changed, 6 insertions(+), 0 deletions(-)
          HERE
          unstylize(stderr.string).should eql(expected)
        end

        it "it can also do the --patch format" do
          with_this_stash
          app.invoke %w(show derp --patch -s).push(gsu_tmpdir.join('stashes').to_s)
          expected = (<<-HERE.unindent)
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
          unstylize(stderr.string).should eql(expected)
        end
      end

      describe "pop" do
        it "which moves the stashed files back" do
          gsu_tmpdir.prepare.touch_r %w(
            stashes/dingle/one-dir/one-file.txt
            stashes/dingle/two-dir/three-dir/three-file.txt
            stashes/dingle/four-dir-never-see/fifth-dir-empty/
            stashes/dingle/two-file.txt
            stashes/beta/whatever.txt
            working-dir/
          )
          working_dir = gsu_tmpdir.join('working-dir')
          stashes_abspath = gsu_tmpdir.join('stashes').expand_path.to_s
          cd working_dir.to_s, -> _ do
            args = %w(pop dingle -s)
            args.push stashes_abspath
            app.invoke args
          end
          actual = `cd #{working_dir} ; find . -mindepth 1`
          expected = <<-HERE.unindent
            ./one-dir
            ./one-dir/one-file.txt
            ./two-dir
            ./two-dir/three-dir
            ./two-dir/three-dir/three-file.txt
            ./two-file.txt
          HERE
          actual.should eql(expected)
        end
      end
    end
  end
end
