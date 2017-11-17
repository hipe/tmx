require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - workspace create (the action is called 'init')" do

    TS_[ self ]
    use :memoizer_methods
    use :want_CLI_or_API
    use :operations

    context "(successfully)" do

      it "succeeds" do
        _tuple || fail
      end

      it "the file is there and its content looks OK" do

        a = _tuple

        _path = ::File.join a[-2], a.last

        _io = ::File.open _path

        o = TestSupport_::Want_Line::Scanner.via_line_stream _io

        o.next_line =~ /\A# created by tan man \d{4}-\d\d-\d\d \d\d:\d\d:\d\d/ or fail

        o.next_line.nil? || fail
      end

      it "emits about creating the intermediate directory" do

        _ev = _tuple.first
        _content = black_and_white _ev
        _content =~ /\bcreating directory\b.+\bpp-qq\b/ or fail
      end

      it "emits about creating the file" do
        _ev = _tuple[1]
        _content = black_and_white _ev
        _content =~ /\Acreated xyz\.ohai \(\d+ bytes\)\z/ or fail
      end

      shared_subject :_tuple do

        td = volatile_tmpdir
        td.prepare
        empty_work_dir = td.path

        config_filename = 'pp-qq/xyz.ohai'

        call_API(
          :workspace, :init,
          :path, empty_work_dir,
          :config_filename, config_filename,
        )

        a = []
        want :info, :creating_directory do |ev|
          a.push ev
        end

        want :info, :collection_resource_committed_changes do |ev|
          a.push ev
        end

        want_result NIL

        a.push empty_work_dir, config_filename
        a
      end
    end

    # ==
    # ==
  end
end
