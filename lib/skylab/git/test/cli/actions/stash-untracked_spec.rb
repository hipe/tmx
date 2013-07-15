require_relative 'test-support'

module Skylab::Git::TestSupport::Actions::Stash_Untracked

  ::Skylab::Git::TestSupport::Actions[ self ]

  include CONSTANTS

  # ( no Q_uickie because of `.stub`-ing below )

  tdpn = ::Skylab.tmpdir_pathname.join 'gsu-xyzzy'

  gsu_tmpdir = TestSupport::Tmpdir.new tdpn.to_s

  const_set :GitStashUntracked,
    ( gsu = Git::CLI::Actions::Stash_Untracked )

  describe gsu do

    describe "has an action called" do

      let :app do
        GitStashUntracked::CLI.new nil, stderr, stderr
      end

      def cd path, block
        Git::Services::FileUtils.cd path.to_s, &block
      end

      attr_accessor :cmd_spy

      attr_accessor :debug

      def debug!
        self.debug =  $stderr
        nil
      end

      let :mock_client do
        o = ::Object.new
        o.stub :emit do |type, payload|
          debug and debug.puts("    (dbg: #{ [type, payload].inspect })")
          stderr.puts payload.to_s
        end
        o
      end

      let :stderr do
        o = TestSupport::IO::Spy.standard
        if debug
          o.debug! -> e do
            if ::String === e
              "    (dbg (was string):#{ e.inspect }"
            else
              "    (dbg (was event):#{ [e.type, e.message].inspect })"
            end
          end
        end
        o
      end

      define_method :unstylize, & Headless::CLI::Pen::FUN.unstylize

      def with_popen3_out_as str
        Git::Services::Open3.stub :popen3 do |cmd, &block|
          self.cmd_spy = cmd
          serr = Git::Services::StringIO.new ''
          sout = ::StringIO.new str
          block[ nil, sout, serr ]
        end
      end



      # -- * --


      describe "status" do
        it "which lists untracked files" do
          with_popen3_out_as "derpus\nnerpus/herpus"
          app.invoke %w(status)
          cmd_spy.should eql("git ls-files --others --exclude-standard")
          stderr.string.should match(/nerpus\/herpus/)
        end
      end



      describe "save" do
        it "which moves the untracked files to a stash dir" do
          o = gsu_tmpdir.clear
          o.mkdir 'Stashes'
          o.touch_r %w(
            calc/lippy.txt
            calc/dippy/doopy.txt
            calc/dippy/floopy.txt
          )
          with_popen3_out_as "lippy.txt\ndippy/doopy.txt\ndippy/floopy.txt"
          cd o.join( 'calc' ), -> _ do
            app.invoke ['save', 'foo', '-n']
          end

          actual = stderr.string

          expected = <<-HERE.unindent
            # git ls-files --others --exclude-standard
            mkdir -p ../Stashes/foo
            mv lippy.txt ../Stashes/foo/lippy.txt
            mkdir -p ../Stashes/foo/dippy
            mv dippy/doopy.txt ../Stashes/foo/dippy/doopy.txt
            mv dippy/floopy.txt ../Stashes/foo/dippy/floopy.txt
          HERE
          actual.should eql(expected)
        end
      end



      describe "list" do
        it "which lists the known stashes (just a basic directory listing)" do
          gsu_tmpdir.clear.touch_r %w(
            stashiz/alpha/herpus/derpus.txt
            stashiz/beta/whatever.txt
          )
          o = GitStashUntracked::API::Actions::List.new mock_client
          r = o.invoke stashes_path: gsu_tmpdir.join( 'stashiz' ), verbose: nil
          r.should_not eql( false )
          expected = <<-HERE.unindent
            alpha
            beta
          HERE
          stderr.string.should eql(expected)
          stderr.truncate(0) ; stderr.rewind

          # now, try the same thing thru the CLI
          app.invoke ['list', '-s', "#{ gsu_tmpdir }/stashiz"]
          stderr.string.should eql(expected)
        end
      end


      describe "show" do

        define_method :with_this_stash do
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

        it "by default does the --stat format" do
          with_this_stash
          argv = %w(show derp)
          argv.concat ['-s', gsu_tmpdir.join( 'stashes' ).to_s ]
          app.invoke argv
          expected = <<-HERE.unindent
            flip.txt      | 2 ++
            flop/floop.tx | 4 ++++
            2 files changed, 6 insertions(+), 0 deletions(-)
          HERE
          unstylize(stderr.string).should eql(expected)
        end

        it "it can also do the --patch format" do
          with_this_stash
          argv = %w(show derp)
          argv.concat [ '-s', gsu_tmpdir.join( 'stashes' ).to_s, '-p' ]
          app.invoke argv
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
          gsu_tmpdir.prepare
          gsu_tmpdir.touch_r %w(
            stashes/dingle/one-dir/one-file.txt
            stashes/dingle/two-dir/three-dir/three-file.txt
            stashes/dingle/four-dir-never-see/fifth-dir-empty/
            stashes/dingle/two-file.txt
            stashes/beta/whatever.txt
            working-dir/
          )
          working_dir = gsu_tmpdir.join 'working-dir'
          stashes_abspath = gsu_tmpdir.join( 'stashes' ).expand_path.to_s
          cd working_dir.to_s, -> _ do
            args = %w(pop dingle -s)
            args.push stashes_abspath
            app.invoke args
          end
          actual = `cd #{ working_dir } ; find . -mindepth 1`
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
