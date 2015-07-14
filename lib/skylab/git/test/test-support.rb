require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Git::TestSupport

  Callback_ = ::Skylab::Callback

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self ]

  extend TestSupport_::Quickie

  module ModuleMethods

    define_method :use, -> do
      cache = {}
      -> sym do
        ( cache.fetch sym do

          const = Callback_::Name.via_variegated_symbol( sym ).as_const

          x = if TS_.const_defined? const
            TS_.const_get const
          else
            TestSupport_.fancy_lookup sym, TS_
          end
          cache[ sym ] = x
          x
        end )[ self  ]
      end
    end.call
  end

  module InstanceMethods

    # ~ test-time support

    # ~ ~ time-time configuration of the test-time environment

    attr_accessor :do_debug

    def debug!
      self.do_debug = true  # here we don't trigger anything but elsewhere ..
    end

    def debug_IO
      TestSupport_.debug_IO
    end

    def black_and_white_expression_agent_for_expect_event
      Home_.lib_.brazen::API.expression_agent_instance
    end

    define_method :memoized_tmpdir_, -> do

      o = nil
      -> do
        if o
          o.for self
        else
          o = TestSupport_.tmpdir.memoizer_for self, 'git-xyzzy'
          o.instance
        end
      end
    end.call

    def real_filesystem
      Home_.lib_.system.filesystem
    end
    alias_method :real_filesystem_, :real_filesystem

    def dirs_in_ path
      Callback_::Stream.via_nonsparse_array(
        `cd #{ path } && find . -type d -mindepth 1`.split NEWLINE_ )
    end

    def files_in_ path
      Callback_::Stream.via_nonsparse_array(
        `cd #{ path } && find . -type f`.split NEWLINE_ )
    end

    def subject_API
      Home_::API
    end
  end

  Expect_Event = -> tcc do

    Callback_.test_support::Expect_event[ tcc ]
  end

  Fixture_tree_ = -> sym do

    ::File.join Fixture_trees_[], sym.to_s.gsub( UNDERSCORE_, DASH_ )
  end

  Fixture_trees_ = Callback_.memoize do

    TS_.dir_pathname.join( 'fixture-trees' ).to_path
  end

  DASH_ = '-'
  DOT_ = '.'
  Home_ = ::Skylab::Git
  NEWLINE_ = "\n"
  NIL_ = nil
  UNDERSCORE_ = '_'
end
