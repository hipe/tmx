require_relative '../../test-support'

module Skylab::System::TestSupport

  describe "[sy] filesystem - n11ns - file-related STUB" do

    TS_[ self ]
    use :filesystem_normalizations

    it "(builds in edit mode) STUB" do
      subject_
    end

    def subject_
      Home_::Filesystem::Normalizations::PathBased
    end
  end
end

