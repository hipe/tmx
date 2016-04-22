require_relative '../../test-support'

module Skylab::System::TestSupport

  describe "[sy] doubles - stubbed system - snippet-based" do

    TS_[ self ]
    use :memoizer_methods
    use :doubles_stubbed_system

    context "(general)" do

      it "loads" do
        _subject_class
      end

      it "for now, parsed lazily (this might change)" do

        _path = TestSupport_::Fixtures.file :not_here

        _subject_class.via_path _path
      end
    end

    context "(for this one file, all with one memoized dootily)" do

      it "stdin is nothing - it is ignored for now" do

        _ = __stubbed_stdin
        _ and fail
      end

      it "the stderr (which was not in the snapshot) is the empty stream" do

        _io = __stubbed_stderr
        _x = _io.gets
        _x and fail
      end

      it "the stdout has the lines that were in the snapshot" do

        _io = __stubbed_stdout
        _x = _io.gets
        _x_ = _io.gets
        _x_ and fail
        _x == " M fazoozle/modified.file\u0000" or fail
      end

      it "the exitstatus (which (NOT TESTED) must be present in the snapshot)" do

        _w = __stubbed_wait
        d = _w.value.exitstatus
        d.zero? or fail
      end

      def __stubbed_stdin
        _subject_array.fetch 0
      end

      def __stubbed_stdout
        _subject_array.fetch 1
      end

      def __stubbed_stderr
        _subject_array.fetch 2
      end

      def __stubbed_wait
        _subject_array.fetch 3
      end

      shared_subject :_subject_array do

        _path = path_for_ 'fixture-data/story-1.snippet.rb'

        _sycond = _subject_class.via_path _path

        _sycond.popen3 'woopie', 'modified.file'
      end
    end

    def _subject_class
      Home_::Doubles::Stubbed_System::Snippet_Based
    end
  end
end
