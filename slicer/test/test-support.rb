require 'skylab/slicer'
require 'skylab/test_support'

module Skylab::Slicer::TestSupport

  class << self
    def [] tcc
      tcc.send :define_singleton_method, :use, Use_method___
      tcc.include InstanceMethods___
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  # -
    Use_method___ = -> sym do
      :expect_CLI == sym or fail
      Brazen_.test_support.lib( :CLI_support_expectations )[ self ]
      NIL_
    end
  # -

  module InstanceMethods___

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

  Home_::Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Brazen_ = Home_::Brazen_
  NIL_ = nil
  NOTHING_ = nil
  TS_ = self
end
