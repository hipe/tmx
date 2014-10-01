require_relative '../test-support'

module Skylab::Headless::TestSupport::IO

  ::Skylab::Headless::TestSupport[ self ]

  include CONSTANTS

  Headless_ = Headless_

  module TestLib_

    File_utils = -> do
      Headless_::Library_::FileUtils
    end

    Tmpdir_pathname = -> do
      Headless_::System.defaults.tmpdir_pathname
    end
  end

  CONSTANTS::TestLib_ = TestLib_

end
