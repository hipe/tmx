require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] recursion mags - counterpart directory via [..]" do

    TS_[ self ]
    use :recursion_magnetics

    it "loads" do
      _subject_mag
    end

    it "given one business dir down below, finds counterpart dir" do
      _against my_real_magnetics_directory_, my_real_test_directory_
      _expect_same
    end

    it "given counterpart dir itself, same" do
      _against my_real_counterpart_directory_, my_real_test_directory_
      _expect_same
    end

    it "given lib dir, same" do
      _against ::File.join( sidesystem_path_, 'lib' ), my_real_test_directory_
      _expect_same
    end

    it "given project dir, same" do
      _against sidesystem_path_, my_real_test_directory_
      _expect_same
    end

    def _against arg_path, test_dir

      _nc = selfsame_name_conventions_
      _fs = the_real_filesystem_
      @_result = _subject_mag[ arg_path, test_dir, _nc, _fs ]
    end

    def _expect_same
      __expect my_real_counterpart_directory_
    end

    def __expect path
      if @_result != path
        @_result.should eql path
      end
    end

    def _subject_mag
      Home_::RecursionMagnetics_::CounterpartDirectory_via_ArgumentPath_and_TestDirectory
    end
  end
end
