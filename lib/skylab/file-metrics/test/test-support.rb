require_relative '../core'
require 'skylab/test-support/core'

module Skylab::FileMetrics::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self ]

  extend TestSupport_::Quickie

  FM_ = ::Skylab::FileMetrics

  FM_.lib_.DSL_DSL_enhance_module self, -> do
    block :with_klass
  end

  module ModuleMethods

    def use sym

      case sym
      when :expect_event
        Callback_.test_support::Expect_event[ self ]
      when :classify_common_screen
        CLI::Classify_Common_Screen[ self ]
      else
        raise ::KeyError, sym
      end
      NIL_
    end

    # exeriment - is this worth it? this is for the "nonstandard thing" below
    # that memoized **into** the test context **class**

    define_singleton_method :let, TestSupport_::Let::LET_METHOD

    let :klass do
       Sandbox_.kiss with_klass_value.call
    end

    define_method :__memoized, TestSupport_::Let::MEMOIZED_METHOD
  end

  module InstanceMethods

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      TestSupport_.debug_IO
    end

    def klass  # nonstandard thing: ..
      self.class.klass
    end

    def subject_API
      FM_.application_kernel_
    end

    def black_and_white_expression_agent_for_expect_event
      FM_.lib_.brazen::API.expression_agent_instance
    end
  end

  Fixture_file_ = -> s do

    ::File.join Fixture_file_directory_[], s
  end

  Callback_ = FM_::Callback_

  Fixture_file_directory_ = Callback_.memoize do

    ::File.join Fixture_tree_directory_[], 'fixture-files-one'
  end

  Fixture_tree_directory_ = Callback_.memoize do

    TS_.dir_pathname.join( 'fixture-trees/fixture-tree-one' ).to_path
  end

  module Sandbox_
    TestSupport_::Sandbox.enhance( self ).kiss_with 'KLS_'
  end

  EMPTY_S_ = FM_::EMPTY_S_
  NEWLINE_ = "\n"
  NIL_ = nil
  SPACE_ = FM_::SPACE_
end
