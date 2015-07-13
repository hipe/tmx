require_relative '../../../test-support'

module Skylab::System::TestSupport

  describe "[sy] services - filesystem - n11ns - file-related STUB" do

    extend TS_
    use :services_filesystem_normalizations_support

    it "(builds in edit mode) STUB" do
      subject_
    end

    def subject_
      Home_.services.filesystem :Path_Based
    end
  end
end

