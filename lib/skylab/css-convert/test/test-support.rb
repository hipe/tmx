require_relative '../core'

require 'skylab/headless/core' # unstylize
require 'skylab/test-support/core'

module Skylab::CssConvert::TestSupport
  ::Skylab::TestSupport::Regret[ CssConvert_TestSupport = self ]


  module CONSTANTS
    CssConvert = ::Skylab::CssConvert
    Headless = ::Skylab::Headless
  end


  module InstanceMethods
    include CONSTANTS

    def build_parser klass
      client = cli_instance
      client.set! or fail "failed to bootstrap client! (defaults etc)" # ick
      klass.new client
    end

    def cli_instance
      @cli_instance ||= begin
        o = CssConvert::CLI.new
        o.send(:program_name=, 'nerk')
        a = o.send :io_adapter
        (_streams = %w(outstream errstream)).each do |stream|
          a.send("#{stream}=", ::Skylab::TestSupport::StreamSpy.standard)
        end
        a.define_singleton_method :debug! do
          _streams.each { |s| send(s).debug! }
        end
        o
      end
    end

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
