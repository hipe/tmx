require_relative '../core'

module Skylab::CodeMolester
  Autoloader_.require_sidesystem :TestSupport
end

module Skylab::CodeMolester::TestSupport

  module CONSTANTS
    CodeMolester = ::Skylab::CodeMolester
    Lib_ = CodeMolester::Lib_
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS

  TestSupport::Regret[ CodeMolester_TestSupport = self ]

  CONSTANTS::TMPDIR = TestSupport::Tmpdir.new(
    max_mkdirs: 2,
    path: Lib_::System_default_tmpdir_pathname[].join( 'co-mo' ),
    verbose: false )

  module InstanceMethods
    include CONSTANTS # refer to constants from i.m's
  end
end
