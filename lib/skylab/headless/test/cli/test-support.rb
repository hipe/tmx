require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI

  ::Skylab::Headless::TestSupport[ CLI_TestSupport = self ]

  include CONSTANTS

  MetaHell = MetaHell ; TestSupport = TestSupport

  extend TestSupport::Quickie  # e.g sibling 'path tools'

  module ModuleMethods

    # we are flagrantly breaking the fundamental rules of unit testing for fun:

    def klass cls_i, & cls_p

      instance_p = nil ; memoize = MetaHell::FUN::Memoize
      norm_argv_p = serr_a_p = streams_p = nil
      define_method :invoke do |*x_a|
        a = norm_argv_p[ x_a ]
        streams_p[].clear_buffers
        serr_a_p = memoize[ -> do
          streams_p[].errstream.string.split "\n"
        end ]
        _client = instance_p[]
        @result = _client.invoke a
      end

      norm_argv_p = -> x_a do
        1 == x_a.length and a = ::Array.try_convert( x_a.first )
        a || x_a
      end

      streams_p = memoize[ -> do
        TestSupport::IO::Spy::Triad.new
      end ]

      class_p = nil
      instance_p = memoize[ -> do
        _cls = class_p[]
        _3 = streams_p[].values
        _cls.new( * _3 )
      end ]

      class_p = memoize[ -> do
        cls = CLI_TestSupport.const_set cls_i, ::Class.new
        cls.instance_variable_set :@dir_pathname, false
        cls.class_exec( & cls_p )
        cls
      end ]

      define_method :serr_a do
        serr_a_p[]
      end

      define_method :debug! do
        streams_p[].debug!
      end
    end
  end

  Probably_existant_tmpdir__ = -> do
    p = -> do_debug do
      td = CLI_TestSupport.tmpdir
      do_debug and td.debug!
      td.exist? or td.prepare
      p = -> _ { td } ; td  # not failsafe
    end
    -> yes { p[ yes ] }
  end.call

  module InstanceMethods

    include CONSTANTS

    # ~ test-phase support

    def from_workdir &p
      r = nil
      Headless::Services::FileUtils.cd workdir do
        r = p[]
      end ; r
    end

    def workdir
      Probably_existant_tmpdir__[ do_debug ]
    end

    # ~ assertion-phase support

    def expect_usage_line_with s
      expect :styled, "usage: #{ s }"
    end

    def expect_invite_line_with s
      expect :styled, "use #{ s } -h for help"
    end

    def expect * x_a
      line = serr_a.shift or fail "expected more serr lines, had none"
      if :styled == x_a[ 0 ]
        x_a.shift
        line_ = Headless::CLI::Pen::FUN::Unstyle_styled[ line ]
        line_ or raise "expected line to be styled, was not: #{ line.inspect }"
        line = line_
      end
      x = x_a.shift
      x_a.length.zero? or raise ::ArgumentError, "unexpected: #{ x_a[0].class }"
      if x.respond_to? :named_captures
        line.should match x
      else
        line.should eql x
      end
    end

    def expect_no_more_serr_lines
      number_of_reamaining_stderr_lines.zero? or fail "expected no more lines#{
        }, had: #{ serr_a.fetch( 0 ).inspect }"
    end

    def expect_a_few_more_serr_lines
      a_few_more.should be_include number_of_reamaining_stderr_lines
    end

    define_method :a_few_more, MetaHell::FUN::Memoize[ -> { 1..2 } ]

    def number_of_reamaining_stderr_lines
      serr_a.length
    end

    let :serr_a do
      bake_serr_a
    end

    def expect_neutral_result
      @result.should be_nil
    end

    def expect_failed
      expect_no_more_serr_lines
      @result.should eql false
    end

    def expect_text
      FUN.expect_text
    end
  end
end
