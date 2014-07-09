require_relative '../core'

require 'skylab/headless/test/test-support' # gives us h.l core and t.s core
                                            # unstyle


module Skylab::CssConvert::TestSupport
  ::Skylab::TestSupport::Regret[ CssConvert_TestSupport = self ]


  module CONSTANTS
    CssConvert = ::Skylab::CssConvert
    Headless_ = CssConvert::Headless_
    TestSupport_ = ::Skylab::TestSupport
  end

  include CONSTANTS

  extend TestSupport_::Quickie

  module InstanceMethods
    include CONSTANTS

    def build_parser klass
      client = cli_instance
      client.set! or fail "failed to bootstrap client! (defaults etc)" # ick
      klass.new client
    end

    def cli_instance
      @cli_instance ||= begin
        streams = TestSupport_::IO::Spy::Triad.new
        _a = streams.values
        app = CssConvert::CLI.new( * _a )
        app.send :program_name=, 'nerk'
        if do_debug
          streams.values.each { |io| io.debug! if io }
        end
        app
      end
    end

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def fixture_path tail
      CssConvert.dir_pathname.join('test/fixtures', tail)
    end

    def parse_css_in_file pathname
      build_parser(CssConvert::CSS::Parser).parse_string pathname.read
    end

    def parse_directives_in_file pathname
      build_parser(CssConvert::Directive::Parser).parse_string pathname.read
    end

    define_method :unstyle, & Headless_::CLI::Pen::FUN.unstyle
  end
end
