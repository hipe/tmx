require 'skylab/file_metrics'
require 'skylab/test_support'

module Skylab::FileMetrics::TestSupport

  def self.[] tcc
    tcc.extend Module_Methods___
    tcc.include Instance_Methods___
  end

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  module Module_Methods___

    cache = {}
    define_method :use do | sym |
      _ = cache.fetch sym do
        x = TestSupport_.fancy_lookup sym, TS_
        cache[ sym ] = x
        x
      end
      _[ self ]
    end
  end

  module Instance_Methods___

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      TestSupport_.debug_IO
    end

    def _NOT_USED_2_klass  # nonstandard thing: ..
      self.class._NOT_USED_3_klass
    end

    def subject_API
      Home_.application_kernel_
    end

    def black_and_white_expression_agent_for_expect_event
      Home_.lib_.brazen::API.expression_agent_instance
    end
  end

  # -- for `use`

  Expect_Event = -> tcc do
    Callback_.test_support::Expect_event[ tcc ]
  end

  # --

  Fixture_file_ = -> s do

    ::File.join Fixture_file_directory_[], s
  end

  Home_ = ::Skylab::FileMetrics

  Callback_ = Home_::Callback_

  Fixture_file_directory_ = Callback_.memoize do

    ::File.join Fixture_tree_directory_[], 'fixture-files-one'
  end

  Fixture_tree_directory_ = Callback_.memoize do

    TS_.dir_pathname.join( 'fixture-trees/fixture-tree-one' ).to_path
  end

  module Sandbox_
    TestSupport_::Sandbox.enhance( self ).kiss_with 'KLS_'
  end

  Callback_::Autoloader[ self, ::File.dirname( __FILE__ ) ]

  EMPTY_S_ = Home_::EMPTY_S_
  NEWLINE_ = "\n"
  NIL_ = nil
  SPACE_ = Home_::SPACE_
  TS_ = self
end
