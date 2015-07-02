require_relative '../test-support'

module Skylab::CodeMolester::TestSupport::Config

  ::Skylab::CodeMolester::TestSupport[ self ]

  module Constants
    SE_ = ::STDERR
    Do_invoke_ = -> do
      a = ::ARGV
      if (( idx = a.index '-x' ))
        a[ idx ] = nil
        a.compact!
        TestSupport_::Quickie.do_not_invoke!
        true
      end
    end
  end

  include Constants

  TestSupport_::Quickie.enable_kernel_describe

  Home_ = Home_

end
