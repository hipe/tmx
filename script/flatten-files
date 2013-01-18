#!/usr/bin/env ruby -w

require 'fileutils'
require 'optparse'
require 'pathname'

module Skylab end
module Skylab::FlattenFiles
  class Headless < ::Struct.new(:indir, :outdir, :dry)
    include ::FileUtils::Verbose
  protected
    def error msg
      emit(:error, msg)
      false
    end
    def invoke
      validate_args or return
      prepare_outdir or return
      count = 0
      ::Pathname.glob(indir.join('**/*')).each do |file|
        file.directory? and next
        dest = outdir.join(file.basename)
        if dest.exist?
          info("skipping #{file}, destination exists: #{dest}")
          next
        end
        count += 1
        mv(file.to_s, dest.to_s, noop: dry)
      end
      info "moved #{count} files."
    end
    def prepare_outdir
      outdir.exist? or mkdir(outdir.to_s, noop: dry)
      if outdir.exist? and ! outdir.directory?
        return error("must be directory: #{outdir}")
      end
      true
    end
    def validate_args
      self.indir = ::Pathname.new(indir)
      self.outdir = ::Pathname.new(outdir)
      indir.exist? or return error("must exist: #{indir}")
      # outdir can either exist or not exist
      true
    end
  end
  class CLI < Headless
    def invoke argv
      parse_argv(argv) or return
      super()
    end
    protected
    def info msg
      emit(:info, "(#{program_name} #{msg})")
      true
    end
    def initialize
      @errstream = $stderr
      @fileutils_output = errstream
      @fileutils_label = "#{program_name}: "
      @option_parser = nil
    end
    def emit(type, data) ; errstream.puts(data) end
    attr_reader :errstream
    def option_parser
      @option_parser ||= begin
        o = ::OptionParser.new
        o.banner = usage_line
        o.separator "\ndescription: all files in <infolder> recursive,\n" <<
          "  move them to <outfolder>.  on name collision, file is skipped.\n\n"
        o.separator 'options:'
        o.on('-n', '--dry-run', 'Dry run.') { self.dry = true }
        o
      end
    end
    NUM_ARGS = 2
    def parse_args argv
      (no = argv.length) == NUM_ARGS or
        return usage("expecting #{NUM_ARGS} had #{no} args")
      no = argv.detect { |s| s =~ /\A-/ } and return usage("filename? #{no}")
      self.indir, self.outdir = argv
      true
    end
    def parse_argv argv
      parse_opts(argv) or return
      parse_args argv
    end
    def parse_opts argv
      option_parser.parse! argv
    rescue ::OptionParser::ParseError => e
      usage e
    end
    def program_name
      (@program_name ||=nil) || ::File.basename($0, '.*')
    end
    def usage msg=nil
      emit(:info, msg) if msg
      emit(:info, usage_line)
      emit(:info, "try #{program_name} -h for more help")
      false
    end
    def usage_line
      "usage: #{program_name} [opts] <infolder> <outfolder>"
    end
  end
end

Skylab::FlattenFiles::CLI.new.invoke(ARGV) if __FILE__ == $PROGRAM_NAME
