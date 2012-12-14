require_relative '../test-support'

module Skylab::Issue::TestSupport::Models::Issues::File
  ::Skylab::Issue::TestSupport::Models::Issues[ File_TestSupport = self ]


  include CONSTANTS


  extend TestSupport::Quickie # try loading test files directly with `ruby -w`


  module InstanceMethods

    def fixture_pathname basename
      File_TestSupport.dir_pathname.join "fixtures/#{ basename }"
    end
  end
end
