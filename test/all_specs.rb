#!/usr/bin/env ruby -w

require 'optparse'
dry_run = false
OptionParser.new do |op|
  op.separator "Description: runs all known tests in this package."
  op.on('-h', '--help', "This screen.") { $stderr.puts op ; exit }
  op.on('-n', '--dry-run', "Do not run tests, just list.") { dry_run = true }
end.parse!(ARGV)


gemroot = File.expand_path('../..', __FILE__)

Subgem = Struct.new(:name, :path, :spec_subdir, :spec_paths)
names = []
subgems = Hash.new { |h, k| names.push(k) ; h[k] = Subgem.new(k, nil, nil, []) }

subgem_paths = [* Dir["#{gemroot}/lib/skylab/*"], '.']

subgem_paths.each do |dirpath|
  subgem = subgems[File.basename(dirpath)]
  subgem.path = dirpath
  if File.exist?(p = "#{subgem.path}/test")
    if (full_specpaths = Dir["#{p}/**/*_spec.rb"]).any?
      subgem.spec_subdir = p
      subgem.spec_paths = full_specpaths
    end
  end
end

data_table = names.map do |name|
  subgem = subgems[name]
  num_tests = subgem.spec_subdir ? subgem.spec_paths.count : 0
  { :subgem_name => subgem.name, :num_tests => num_tests }
end

require File.expand_path('../../lib/skylab/face/cli/tableize', __FILE__)
require File.expand_path('../../lib/skylab/face/path-tools', __FILE__)

Skylab::Face::Cli::Tableize.tableize(data_table, $stderr)

files = names.map do |name|
  subgems[name].spec_paths
end.flatten

if files.any?
  $stderr.puts("\nThese are the spec files:")
  files.each { |path| puts "#{Skylab::Face::PathTools.pretty_path path}" }
else
  $stderr.puts("\nNo specs found!")
end


module Skylab ; end

module Skylab::Tests
  class Plumbing
    attr_accessor :dry_run
    def initialize opts
      opts.each { |k, v| send("#{k}=", v) }
    end
    def invoke
      if @dry_run
        $stderr.puts "# skipping above per dry run."
      else
        run_tests
      end
    end
    def run_tests
      require 'rspec/autorun'
      test_files.each { |file| require file }
      $stderr.puts "Done loading the above #{files.count} spec files.\n\n"
    end
    attr_accessor :test_files
  end
end

if __FILE__ == $PROGRAM_NAME
  Skylab::Tests::Plumbing.new(dry_run: dry_run, test_files: files).invoke
end

