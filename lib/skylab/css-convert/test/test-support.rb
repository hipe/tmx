require_relative '../core'

require 'skylab/headless/test/test-support' # gives us h.l core and t.s core
                                            # unstylize


module Skylab::CssConvert::TestSupport
  ::Skylab::TestSupport::Regret[ CssConvert_TestSupport = self ]


  module CONSTANTS
    CssConvert = ::Skylab::CssConvert
    Headless = ::Skylab::Headless
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS

  extend TestSupport::Quickie

  module InstanceMethods
    include CONSTANTS

    def build_parser klass
      client = cli_instance
      client.set! or fail "failed to bootstrap client! (defaults etc)" # ick
      klass.new client
    end

    def cli_instance
      @cli_instance ||= begin
        streams = Headless::TestSupport::CLI::IO_Spy_Group.new
        app = CssConvert::CLI.new(* streams.values )
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

    define_method :unstylize, & Headless::CLI::Pen::FUN.unstylize
  end
end
