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

    if false

    # ~ ~ support for building clients

    # ~ ~ ~ simple one-stream spying

    def outstream
      @outstream ||= bld_outstream
    end

    def bld_outstream
      @out_a ||= [ ]
      Mock_Stream__.new do |line|
        @do_debug and TestSupport_::System.stderr.puts "(out: #{ line })"
        @out_a << line ; nil
      end
    end
    #
    class Mock_Stream__ < ::Proc
      alias_method :puts, :call
    end

    # ~ assertion-time support (very primitive)

    def expect exp
      _expect @out_a, exp
    end

    def expect_err exp
      _expect @err_a, exp
    end

    def _expect a, exp
      (( line = a.shift )) or fail "expected more output lines"
      if exp.respond_to? :named_captures
        line.should match( exp )
      else
        line.should eql( exp )
      end
    end

    def expect_final str
      expect str
      @out_a.length.should eql( 0 )
    end
    end
  end

  Fixture_tree_ = -> sym do

    ::File.join Fixture_trees_[], sym.to_s.gsub( UNDERSCORE_, DASH_ )
  end

  Fixture_trees_ = Callback_.memoize do

    TS_.dir_pathname.join( 'fixture-trees' ).to_path
  end

  DASH_ = '-'
  Home_ = ::Skylab::Git
  NIL_ = nil
  UNDERSCORE_ = '_'
end
