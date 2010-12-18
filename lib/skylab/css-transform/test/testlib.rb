require File.expand_path('../../lib/css-convert', __FILE__)

require 'ruby-debug'
require 'pp'
require 'stringio'

Hipe__CssConvert__Testlib = true

module Hipe::CssConvert::ExampleHelperMethods
  def new_cli
    Hipe::CssConvert.cli.buffered!
  end
  def fixture_path tail
    File.join('test/fixtures', tail)
  end
  def parse_css_in_file path
    contents = File.read(path)
    p = Hipe::CssConvert.css_parser
    resp = p.parse(contents)
    if resp.nil?
      p # not sure about this! just for debugging?
    else
      resp
    end
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

module Hipe::CssConvert::SexpesqueStructurePatterns
  def distilled_structure sexp
    a = sexp.map[1...sexp.size].map{ |x|
      case x
      when Array ; [true,  distilled_structure(x)]
      else       ; [false, x.class.to_s]              end
    }
    any_true  = a.detect{ |x| x.first == true  }
    any_false = a.detect{ |x| x.first == false }
    if any_true && any_false # mixed elements, failsauce
      [sexp.first, *a.map{ |x| x[1] }]
    elsif any_true # all true
      return [sexp.first, *a.map{ |x| x[1] }]
    else # all false or sexp has no elements, only a name
      return sexp.first # this is where the distillation happens
    end
  end
end

RSpec::Matchers.define :match_the_structure_pattern do |expected|
  extend Hipe::CssConvert::SexpesqueStructurePatterns
  match do |actual|
    expected.inspect == distilled_structure(actual).inspect
  end
  failure_message_for_should do |actual|
    ioa = PP.pp(distilled_structure(actual), StringIO.new)
    ioe = PP.pp(expected, StringIO.new)
    ioa.rewind
    ioe.rewind
    exp = ioe.read
    act = ioa.read
    dif = ::Rspec::Expectations.differ.diff_as_string(act, exp)
    "Sexp did not have the expected structure: #{dif}"
  end
end

RSpec.configure do |c|
  c.include Hipe::CssConvert::ExampleHelperMethods
end
