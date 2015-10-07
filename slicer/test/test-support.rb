require 'skylab/slicer'
require 'skylab/test_support'

module Skylab::Slicer::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self, ::File.dirname( __FILE__ ) ]

  extend TestSupport_::Quickie

  module ModuleMethods

    def use sym
      :expect_CLI == sym or fail
      Brazen_.test_support.CLI::Expect_CLI[ self ]
      NIL_
    end
  end

  module InstanceMethods

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      TestSupport_.debug_IO
    end

    def subject_CLI
      Home_::CLI
    end

    define_method :get_invocation_strings_for_expect_stdout_stderr, -> do
      s_a = [ 'sli' ]
      -> do
        s_a
      end
    end.call
  end

  Home_ = ::Skylab::Slicer

  Brazen_ = Home_::Brazen_
  NIL_ = nil
end
