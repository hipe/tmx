require File.expand_path('../../lib/css-convert', __FILE__)

require 'ruby-debug'

Hipe__CssConvert__Testlib = true

module Hipe::CssConvert::ExampleHelperMethods
  def new_cli
    Hipe::CssConvert.cli.buffered!
  end
  def fixture_path tail
    File.join('test/fixtures', tail)
  end
  def parse_directives_in_file path
    require Hipe::CssConvert::ROOT + '/grammar/program-parser.rb' # wants wrapper
    p = Hipe::CssConvert::Grammar::ProgramParser.new
    contents = File.read(path)
    puts contents if @debuggy
    resp = p.parse contents
    if ! resp.nil?
      resp.tree
    elsif @debuggy
      puts "got failure:"
      puts p.failure_reason
      nil
    end
  end
end

RSpec.configure do |c|
  c.include Hipe::CssConvert::ExampleHelperMethods
end
