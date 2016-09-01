require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] recursion mags - test directory via argument path" do

    TS_[ self ]
    use :recursion_magnetics

    it "loads" do
      _subject_mag
    end

    it "finds it exactly one level under" do
      _against sidesystem_path_
      _expect my_real_test_directory_
    end

    it "finds it upwards from a path" do
      _against imaginary_path_one_two__
      _expect my_real_test_directory_
    end

    def _against path
      @_result = _subject_mag[ path, name_conventions_, ::File ]
    end

    def _expect path
      if @_result != path
        @_result.should eql path
      end
    end

    def _subject_mag
      Home_::RecursionMagnetics_::TestDirectory_via_ArgumentPath
    end
  end
end
