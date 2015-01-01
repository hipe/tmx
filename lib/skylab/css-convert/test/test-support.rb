require_relative '../core'
require 'skylab/test-support/core'

module Skylab::CSS_Convert::TestSupport

  ::Skylab::TestSupport::Regret[ TS_ = self ]

  module Constants
    CSSC_ = ::Skylab::CSS_Convert
    Headless_ = CSSC_::Headless_
    TestSupport_ = ::Skylab::TestSupport
  end

  include Constants

  extend TestSupport_::Quickie

  TestSupport_::Quickie.enable_kernel_describe

  module InstanceMethods

    include Constants

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def build_parser cls
      client = cli_instance
      client.set! or fail "failed to bootstrap client! (defaults etc)" # ick
      cls.new client
    end

    def cli_instance
      @cli_instance ||= begin
        streams = TestSupport_::IO.spy.triad.new
        _a = streams.values
        app = CSSC_::CLI.new( * _a )
        app.send :program_name=, 'nerk'
        do_debug and streams.debug!
        app
      end
    end

    def fixture_path tail
      CSSC_.dir_pathname.join('test/fixtures', tail)
    end

    def parse_css_in_file pathname
      build_parser(CSSC_::CSS_::Parser).parse_string pathname.read
    end

    def parse_directives_in_file pathname
      build_parser(CSSC_::Directive__::Parser).parse_string pathname.read
    end

    define_method :unstyle, CSSC_.lib_.CLI_lib.pen.unstyle

  end
end
