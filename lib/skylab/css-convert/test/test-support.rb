require_relative '../core'
require 'skylab/test-support/core'

module Skylab::CSS_Convert::TestSupport

  ::Skylab::TestSupport::Regret[ TS_ = self ]

  module Constants
    Home_ = ::Skylab::CSS_Convert
    Headless_ = Home_::Headless_
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
        app = Home_::CLI.new( * _a, [ 'nerk' ] )
        do_debug and streams.debug!
        app
      end
    end

    def fixture_path tail
      Home_.dir_pathname.join('test/fixtures', tail)
    end

    def parse_css_in_file pathname
      build_parser(Home_::CSS_::Parser).parse_path pathname.to_path
    end

    def parse_directives_in_file pathname
      build_parser(Home_::Directive__::Parser).parse_path pathname.to_path
    end

    define_method :unstyle, Home_.lib_.brazen::CLI::Styling::Unstyle

  end
end
