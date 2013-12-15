#!/usr/bin/env ruby -w

require 'pathname'

root = ::Pathname.new(::File.expand_path('../..', __FILE__))

nerps = ::Pathname.glob(root.join('lib/skylab/*/doc/issues.md').to_s)

re = %r{\A#{::Regexp.escape(root.to_s)}/lib/skylab/([^/]+)}

err = STDERR

nerps.each do |path|
  title = re.match(path.to_s)[1]
  err.puts "- #{title}"
  path.open('r') do |fh|
    while line = fh.gets
      err.puts "    - #{line}"
    end
    err.puts
  end
end
