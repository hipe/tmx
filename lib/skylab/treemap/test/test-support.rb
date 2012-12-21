require_relative '../../test-support/core'

require_relative '../cli' # as the entrypoint for this module @todo-in-module

module Skylab::Treemap
  module TestSupport
    [:out, :err].each do |m| # def out_string; err_string
      define_method("#{m}_string") do
        str = send("#{m}_stream").string
        Headless::CLI::Pen::FUN.unstylize[ str ]
      end
    end
    def build_stream_spy
      Skylab::TestSupport::StreamSpy.standard # add .debug! if u want
    end
    def build_tmx_cli
      require 'skylab/tmx/cli'
      Skylab::Tmx::Cli.new(
        program_name: 'tmx',
        out: out_stream,
        err: err_stream
      )
    end
  end
end

