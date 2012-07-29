require_relative '../core'
require 'skylab/test-support/core'

require 'pp'
require 'stringio'

module Skylab::CssConvert::TestSupport
  CssConvert = ::Skylab::CssConvert
  class OutputAdapterSpy < CssConvert::CLI::OutputAdapter
    OUT = 0 ; ERR = 1
    def debug!
      @streams.each(&:debug!)
      self
    end
    def err
      @streams[ERR]
    end
    def initialize
      @streams = 2.times.map { ::Skylab::TestSupport::StreamSpy.standard }
      super(out, err)
    end
    def out
      @streams[OUT]
    end
  end
end

module Skylab::CssConvert::TestSupport::InstanceMethods
  CssConvert = ::Skylab::CssConvert
  TestSupport = CssConvert::TestSupport

  def build_parser klass
    klass.new cli_instance.request_runtime
  end
  def cli_instance
    @cli_instance ||= begin
      o = CssConvert::CLI.new
      o.output_adapter = TestSupport::OutputAdapterSpy.new
      o.program_name = 'nerk'
      o
    end
  end
  def fixture_path tail
    CssConvert.dir.join('test/fixtures', tail)
  end
  def parse_css_in_file pathname
    build_parser(CssConvert::CssParser).parse_string pathname.read
  end
  def parse_directives_in_file pathname
    build_parser(CssConvert::DirectivesParser).parse_string pathname.read
  end
end

module Skylab::CssConvert::SexpesqueStructurePatterns
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
  extend Skylab::CssConvert::SexpesqueStructurePatterns
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
