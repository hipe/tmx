require_relative '../../../test-support'

module Skylab::System::TestSupport

  describe "[sy] services - filesystem - n11ns - existent dir" do

    extend TS_
    use :services_filesystem_normalizations_support

    it "noent - whines" do

      _path = TestSupport_::Data::Universal_Fixtures[ :not_here ]
      against_ _path

      expect_not_OK_event :errno_enoent
      expect_failed
    end

    it "`create_if_not_exist` - creates" do

      td = memoized_tmpdir_.clear
      _path = ::File.join td.path, 'mambazo'

      @result = subject_.with(
        :path, _path,
        :create_if_not_exist,
        & handle_event_selectively )

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
        & handle_event_selectively )

      o.frozen? or fail

      @result = o.against_path _three_lines
      _expect_same
    end

    def _three_lines
      TestSupport_::Data::Universal_Fixtures[ :three_lines ]
    end

    def _expect_same

      expect_not_OK_event :wrong_ftype
      expect_failed
    end

    def subject_
      Home_.services.filesystem :Existent_Directory
    end
  end
end
