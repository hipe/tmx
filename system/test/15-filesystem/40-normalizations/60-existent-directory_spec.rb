require_relative '../../test-support'

module Skylab::System::TestSupport

  describe "[sy] filesystem - n11ns - existent dir" do

    TS_[ self ]
    use :filesystem_normalizations

    it "noent - whines" do

      _path = TestSupport_::Fixtures.file :not_here
      against_ _path

      expect_not_OK_event :enoent
      expect_fail
    end

    it "`create_if_not_exist` - creates" do

      td = memoized_tmpdir_.clear
      _path = ::File.join td.path, 'mambazo'

      @result = subject_.call_via(
        :path, _path,
        :create_if_not_exist,
        & handle_event_selectively_ )

      expect_neutral_event :creating_directory
      expect_no_more_events

      ::File.basename( @result.value_x ).should eql 'mambazo'
    end

    it "against file - whines" do

      _path = _three_lines

      against_ _path

      _expect_same
    end

    it "curry" do

      o = subject_.new_with(
        :create_if_not_exist,
        & handle_event_selectively_ )

      o.frozen? or fail

      @result = o.against_path _three_lines
      _expect_same
    end

    def _three_lines
      TestSupport_::Fixtures.file( :three_lines )
    end

    def _expect_same

      expect_not_OK_event :wrong_ftype
      expect_fail
    end

    def subject_
      Home_.services.filesystem :Existent_Directory
    end
  end
end
