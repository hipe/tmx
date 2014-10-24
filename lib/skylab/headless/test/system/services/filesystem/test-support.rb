require_relative '../test-support'

module Skylab::Headless::TestSupport::System::Services::Filesystem

  ::Skylab::Headless::TestSupport::System::Services[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  Headless_ = Headless_

  module InstanceMethods
    def subject
      super.filesystem
    end
  end

  module TestLib_

    include Constants::TestLib_

    File_utils = -> do
      Headless_::Library_::FileUtils
    end

    Tmpdir_pathname = -> do
      Headless_.system.defaults.dev_tmpdir_pathname
    end

  end

  Constants::TestLib_ = TestLib_
end
