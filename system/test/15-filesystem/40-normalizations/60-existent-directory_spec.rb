require_relative '../../test-support'

module Skylab::System::TestSupport

  describe "[sy] filesystem - n11ns - existent dir" do

    TS_[ self ]
    use :filesystem_normalizations

    it "noent - whines" do

      _path = TestSupport_::Fixtures.file :not_here
      against_ _path

      want_not_OK_event :enoent
      want_fail
    end

    it "`create_if_not_exist` - creates" do

      td = memoized_tmpdir_.clear
      _path = ::File.join td.path, 'mambazo'

      @result = subject_via_plus_real_filesystem_plus_listener_(
        :path, _path,
        :create_if_not_exist,
      )

      want_neutral_event :creating_directory
      want_no_more_events

      ::File.basename( @result.value ).should eql 'mambazo'
    end

    it "against file - whines" do

      _path = _three_lines

      against_ _path

      _want_same
    end

    it "curry" do  # :#cov1.1

      _ = subject_

      o = _.with(
        :create_if_not_exist,
        :filesystem, the_real_filesystem_,
        & listener_ )

      o.frozen? or fail

      @result = o.against_path _three_lines
      _want_same
    end

    def _three_lines
      TestSupport_::Fixtures.file( :three_lines )
    end

    def _want_same

      want_not_OK_event :wrong_ftype
      want_fail
    end

    def subject_
      Home_::Filesystem::Normalizations::ExistentDirectory
    end
  end
end
