require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::DotFile::Manipulus # 0652
  ::Skylab::TanMan::TestSupport::Models::DotFile[ Manipulus = self ]

  module CONSTANTS
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS

  extend TestSupport::Quickie # run some tests without rspec, just `ruby -w`

  module InstanceMethods
    let( :_parser_dir_path ) { Manipulus.dir_path }
  end
end
