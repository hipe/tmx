require_relative '../test-support'

module Skylab::Treemap::TestSupport::CLI
  ::Skylab::Treemap::TestSupport[ CLI_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module InstanceMethods
    include CONSTANTS # `TestSupport` is called upon in i.m's

    def debug!
      stream.sout.debug!
      stream.serr.debug!
      nil
    end

    def serr
      _unstylize :serr
    end

    def sout
      _unstylize :sout
    end

    def _unstylize k
      Headless::CLI::Pen::FUN.unstylize[ stream[k].string ]
    end

    stream_struct = ::Struct.new :sout, :serr

    define_method :stream do
      @stream ||= begin
        o = stream_struct.new(
          TestSupport::StreamSpy.standard, TestSupport::StreamSpy.standard )
      end
    end

    def tmx_cli # (was [#051] legacy test wiring)
      @tmx_cli ||= begin
        require 'skylab/tmx/cli'
        cli = ::Skylab::Tmx::Cli.new( program_name: 'tmx',
          out: stream.sout, err: stream.serr )
        cli
      end
    end
  end
end
