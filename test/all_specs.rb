#!/usr/bin/env ruby

require 'ruby-debug'
gemroot = File.expand_path('../..', __FILE__)

Subgem = Struct.new(:name, :path, :spec_subdir, :spec_paths)
names = []
subgems = Hash.new { |h, k| names.push(k) ; h[k] = Subgem.new(k, nil, nil, []) }

Dir["#{gemroot}/lib/skylab/*"].each do |dirpath|
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

require 'rspec/autorun'
files.each { |file| require file }
$stderr.puts "Done loading the above #{files.count} spec files.\n\n"
