require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Git::TestSupport

  ::Skylab::TestSupport::Regret[ self ]

  module CONSTANTS
    Git = ::Skylab::Git
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS

  TestSupport = TestSupport

  module InstanceMethods

    attr_accessor :do_debug

    def debug!
      @do_debug = true
    end

    def expect exp
      _expect @out_a, exp
    end

    def _expect a, exp
      (( line = a.shift )) or fail "expected more output lines"
      if exp.respond_to? :named_captures
        line.should match( exp )
      else
        line.should eql( exp )
      end
    end

    def expect_err exp
      _expect @err_a,exp
    end

    def expect_final str
      expect str
      @out_a.length.should eql( 0 )
    end

    def outstream
      @outstream ||= begin
        @out_a ||= [ ]
        Mock_Stream_.new do |line|
          @do_debug and TestSupport::Stderr_[].puts "(out: #{ line })"
          @out_a << line
          nil
        end
      end
    end

    class Mock_Stream_ < ::Proc
      alias_method :puts, :call
    end
  end
end
