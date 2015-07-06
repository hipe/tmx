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
          x = Home_.lib_.plugin::Bundle::Fancy_lookup[ sym, TS_ ]
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

      td = nil  # :+#nasty_OCD_memoize

      -> do

        if td

          yes = do_debug
          yes_ = td.be_verbose

          if yes
            if ! yes_
              td = td.new_with :debug_IO, debug_IO, :be_verbose, true
            end
          elsif yes_ && ! yes
            td = td.new_with :be_verbose, false
          end
        else

          _path = real_filesystem_.tmpdir_pathname.join 'gi-xyzzy'

          td = TestSupport_.tmpdir.new_with(
            :path, _path,
            :be_verbose, do_debug,
            :debug_IO, debug_IO )
        end

        td
      end
    end.call

    def real_filesystem_
      Home_.lib_.system.filesystem
    end

    def dirs_in_ path
      Callback_::Stream.via_nonsparse_array(
        `cd #{ path } && find . -type d -mindepth 1`.split NEWLINE_ )
    end

    def files_in_ path
      Callback_::Stream.via_nonsparse_array(
        `cd #{ path } && find . -type f`.split NEWLINE_ )
    end
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
