require_relative '../test-support'

module Skylab::TaskExamples::TestSupport

  describe "[te] task-types - get", slow: true do

    # NOTE - requires this to be running: task_examples/test/script/test-server

    # #significance: the first task that actually pings an "external" service..

    TS_[ self ]
    use :memoizer_methods
    use :want_event
    use :task_types

    def subject_class_
      Task_types_[]::Get
    end

    context "essential" do

      it "loads" do
        subject_class_
      end
    end

    yes = true

    define_method :build_arguments_ do

      if yes
        yes = false
        run_file_server_if_not_running_  # NOTE OK to skip during development
      end

      _build_dir = _prepare_and_produce_build_directory

      [
        :build_dir, _build_dir,
        :from, _from,
        :get, _get,
      ]
    end

    context "request one file that does not exist" do

      shared_state_

      def _from
        NIL_
      end

      def _get
        ::File.join _local_url, "not/there.txt"
      end

      def _prepare_and_produce_build_directory
        the_empty_directory_  # never writes
      end

      it "fails" do
        fails_
      end

      it "fake shell.." do

        _be_this_message = match %r(\Acurl -o\b)

        _be_this = be_emission :info, :expression, :fake_shell do |y|
          expect( y.fetch 0 ).to _be_this_message
        end

        expect( first_emission ).to _be_this
      end

      it "expresses" do

        _be_this_msg = _be_message_about_not_found 'not/there.txt'

        _be_this = be_emission :error, :expression, :"404" do |y|
          expect( y.fetch 0 ).to _be_this_msg
        end

        expect( last_emission ).to _be_this
      end
    end

    context "request one file that exists (also different argument string math)" do

      shared_state_

      def _from
        _local_url
      end

      def _get
        "some-file.txt"
      end

      def _prepare_and_produce_build_directory
        empty_tmpdir_.path
      end

      it "succeeds" do
        succeeds_
      end

      it "puts it in the basket, the requested file, byte per byte" do

        tail = _get

        state_
        created_path = ::File.join BUILD_DIR, tail

        _d = ::File.stat( created_path ).size
        expect( _d ).to be_nonzero

        _source_path = ::File.join FIXTURES_DIR, tail

        _orig = read_file_ _source_path
        _created = read_file_ created_path
        _orig == _created or fail
      end
    end

    context "request several files of which some do not exist" do

      shared_state_

      it "fails" do
        fails_
      end

      def _from
        _local_url
      end

      def _get
        %w(nope-not-there.txt another-file.txt)
      end

      def _prepare_and_produce_build_directory
        empty_tmpdir_.path
      end

      it "fails" do
        fails_
      end

      it "emits 404" do

        _be_this_msg = _be_message_about_not_found 'nope-not-there.txt'

        _be_this = be_emission :error, :expression, :"404" do |y|
          expect( y.fetch 0 ).to _be_this_msg
        end

        expect( second_emission ).to _be_this
      end

      it "still gets the files that it got" do

        _hi = _dir_files
        expect( _hi ).to eql [ 'another-file.txt' ]
      end
    end

    context "request several files of which all exist" do

      shared_state_

      def _from
        _local_url
      end

      def _get
        %w( some-file.txt another-file.txt )
      end

      def _prepare_and_produce_build_directory
        empty_tmpdir_.path
      end

      it "succeeds" do
        succeeds_
      end

      it "emits only shell lines" do

        yes = 0 ; no = 0
        emission_array.each do |em|
          if :fake_shell == em.channel_symbol_array.last
            yes += 1
          else
            no += 1
          end
        end

        expect( no ).to be_zero
        expect( yes ).to be_nonzero
      end

      it "puts all of the files in the basket" do

        state_

        expect( _dir_files ).to eql %w( another-file.txt some-file.txt )
      end
    end

    def _be_message_about_not_found tail

      _rx = %r(\AFile not found: http:.+#{ ::Regexp.escape tail }\z)

      match _rx
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

    _LOCAL_URL = 'http://localhost:1324/'
    define_method :_local_url do
      _LOCAL_URL
    end
  end
end
