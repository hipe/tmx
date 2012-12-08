require_relative '../core'

require 'skylab/test-support/core'


module ::Skylab::CodeMolester::TestSupport
  include ::Skylab # TestSupport

  TestSupport::Regret[ CodeMolester_TestSupport = self ]

  TMPDIR = TestSupport::Tmpdir.new ::Skylab::TMPDIR_PATHNAME.join('co-mo')

  module CONSTANTS
    CodeMolester = ::Skylab::CodeMolester
  end

  include CONSTANTS

end
