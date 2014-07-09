require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Git::TestSupport

  Git_ = ::Skylab::Git
    Autoloader_ = Git_::Autoloader_
  TestLib_ = ::Module.new
  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ self ]

  module CONSTANTS
    Git_ = Git_
    TestSupport_ = TestSupport_
    TestLib_ = TestLib_
  end

  module InstanceMethods

    # ~ test-time support

    # ~ ~ time-time configuration of the test-time environment

    attr_accessor :do_debug

    def debug!
      self.do_debug = true  # here we don't trigger anything but elsewhere ..
    end

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

  module CONSTANTS::TestLib_

    Headless__ = Git_::Lib_::Headless__

    IO_spy_group = -> do
      TestSupport_::IO::Spy::Group
    end

    Stderr = -> do
      TestSupport_::System.stderr
    end

    Tmpdir = -> do
      TestSupport_::Tmpdir
    end

    Tmpdir_pathname = -> do
      Headless__[]::System.defaults.tmpdir_pathname.join 'gsu-xyzzy'
    end
  end
end
