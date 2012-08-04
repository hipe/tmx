require_relative '../core'
require 'skylab/test-support/core'

module Skylab::CssConvert
  module TestSupport end
  module TestSupport::InstanceMethods
    include ::Skylab::Headless::CLI::IO::Pen::InstanceMethods # unstylize

    def build_parser klass
      rt = cli_instance.request_runtime
      rt.parameter_controller.set! or
        fail("failed to bootstrap params! (defaults etc)") # ick sorry
      klass.new rt
    end

    def cli_instance
      @cli_instance ||= begin
        a = (o = CssConvert::CLI.new).io_adapter
        o.send(:program_name=, 'nerk')
        (_streams = %w(outstream errstream)).each do |stream|
          a.send("#{stream}=", ::Skylab::TestSupport::StreamSpy.standard)
        end
        a.singleton_class.send(:define_method, :debug!) do
          _streams.each { |s| send(s).debug! }
        end
        o
      end
    end

    def fixture_path tail
      CssConvert.dir.join('test/fixtures', tail)
    end

    def parse_css_in_file pathname
      build_parser(CssConvert::CssParser).parse_string pathname.read
    end

    def parse_directives_in_file pathname
      build_parser(CssConvert::DirectivesParser).parse_string pathname.read
    end
  end
end
