require_relative '../test-support'

module Skylab::CodeMolester::TestSupport::Config

  ::Skylab::CodeMolester::TestSupport[ self ]

  module CONSTANTS
    SE_ = $stderr
    Do_invoke_ = -> do
      a = ::ARGV
      if (( idx = a.index '-x' ))
        a[ idx ] = nil
        a.compact!
        TestSupport::Quickie.do_not_invoke!
        true
      end
    end
  end
end
