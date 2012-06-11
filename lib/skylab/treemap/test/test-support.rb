require_relative '../../test-support/test-support'

require_relative '../cli' # as the entrypoint for this module

module Skylab::Treemap
  module TestSupport
    [:out, :err].each do |m| # def out_string; err_string
      define_method("#{m}_string") do
        Skylab::Porcelain::TiteColor.unstylize send("#{m}_stream").string
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
      ) do
        on_info    { |e| err_stream.puts e }
        on_error   { |e| err_stream.puts e }
        on_payload { |e| out_stream.puts e }
      end
    end
  end
end

