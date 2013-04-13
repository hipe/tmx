require_relative '../core'

require 'skylab/test-support/core'

module ::Skylab::CodeMolester::TestSupport
  include ::Skylab # TestSupport

  TestSupport::Regret[ CodeMolester_TestSupport = self ]

  TMPDIR = TestSupport::Tmpdir.new(
    ::Skylab.tmpdir_pathname.join( 'co-mo' ),
    verbose: false
  )

  module CONSTANTS
    include ::Skylab # *all subproducts!*

    TMPDIR = TMPDIR
  end

  include CONSTANTS


  module InstanceMethods
    include CONSTANTS # refer to constants from i.m's
  end
end
