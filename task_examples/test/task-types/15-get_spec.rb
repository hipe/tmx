require_relative '../test-support'

module Skylab::TaskExamples::TestSupport

  describe "[te] task-types - get" do

    TS_[ self ]
    use :task_types

    def subject_class_
      Task_types_[]::Get
    end

    context "when requesting one file", slow:true do

      context "that exists" do

        shared_state_

        it "succeeds" do
          succeeds_
        end

        it "shows a shell equivalent (with curl) of the action" do

          expect_only_ :shell, %r(\Acurl -o [^ ]+ [^ ]+/some-file\.txt\z)
        end

        it "puts it in the basket, the requested file, byte per byte" do

          state_
          path = ::File.join BUILD_DIR, uri
          file_exists_( path ) or fail
          d = ::File.stat( path ).size
          d.should be_nonzero
          read_file_( path ).should eql read_file_( source_file_path )
        end
      end

      context "that does not exit" do

        shared_state_

        it "fails" do
          fails_
        end

        it "expresses" do

          _rx = %r(\AFile not found: http:.+not/there\.txt\z)

          expect_eventually_ :error, _rx
        end

        def uri
          "not/there.txt"
        end
      end

      def from
        NIL_
      end

      def source_file_path
        @___source_file_path ||= ::File.join FIXTURES_DIR, uri
      end

      def get
        ::File.join host, uri
      end

      def uri
        "some-file.txt"
      end
    end

    context "when requesting several files", slow:true do

      context "that do exist" do

        shared_state_

        it "puts all of the files in the basket" do

          state_

          _dir_files.should eql %w( another-file.txt some-file.txt )
        end

        it "expresses" do

          expect_ :shell, %r(./some-file\.txt\z)
          expect_only_ :shell, %r(./another-file\.txt\z)
        end

        def from
          host
        end

        def get
          %w(some-file.txt another-file.txt)
        end
      end

      context "of which a subset do not exist" do

        shared_state_

        it "fails" do
          fails_
        end

        it "whines about the files that don't exist" do

          _s = "File not found: http://localhost:1324/not-there.txt"
          expect_eventually_ :error, _s
        end

        it "still gets the files that do exist" do

          _dir_files.should eql %w( another-file.txt )
        end

        def from
          host
        end

        def get
          %w(not-there.txt another-file.txt)
        end
      end

      def _dir_files

        _dir = ::Dir.new BUILD_DIR
        s_a = _dir.entries.reduce [] do | m, s |
          if DOT_BYTE_ != s.getbyte( 0 )
            m.push s
          end
          m
        end
        s_a.sort!
        s_a
      end
    end

    def context_
      {
        build_dir: build_dir,
      }
    end

    def build_arguments_
      {
        from: from,
        get: get,
      }
    end

    def build_dir
      BUILD_DIR
    end

    memoize_ :host do
      'http://localhost:1324/'
    end

    # (hack a before(:all) and a before(:each) -

    yes = true ; for_D = nil ; for_no_D = nil

    define_method :before_execution_ do

      if yes
        yes = false
        run_file_server_if_not_running_
      end

      dc = if do_debug
        for_D ||= build_build_directory_controller_
      else
        for_no_D ||= build_build_directory_controller_
      end
      dc.prepare
      NIL_
    end
  end
end
