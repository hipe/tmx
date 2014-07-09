require 'open3'

self._ARCHIVED

module Skylab::TMX::Modules::CLI
  module Diffland
    extend Skylab::F_ace::Colors
    class << self
      def run cmd, opts={}
        out = opts.fetch :stdout do Headless::CLI::IO.some_outstream_IO end
        err = opts.fetch :stderr do Headless::CLI::IO.some_errstream_IO end
        colors = opts.key?(:colors) ? opts[:colors] : true
        colors and (! out.tty? || ! err.tty?) and colors = false
        true == colors and colors = [
          lambda { |line, no| /^- / =~ line and :red },
          lambda { |line, no| /^\+ / =~ line and :green },
          lambda do |line, no|
            (1..4).include?(no) and /^(?:diff|index|--- |\+\+\+)/ =~ line and :red
          end
        ]
        line_no = 0
        Open3.popen3(cmd) do |sin, sout, serr|
          do_line = lambda do |line, _out|
            line_no += 1
            clr = nil
            colors and colors.detect { |proc| clr = proc[line, line_no] }
            line.strip!
            _out.puts( clr ? style(line, clr) : line )
          end
          ssout = true; sserr = true
          do_line[ssout, out] while ssout and ssout = sout.gets
          do_line[sserr, err] while sserr and sserr = serr.gets
        end
      end
    end
  end
end
