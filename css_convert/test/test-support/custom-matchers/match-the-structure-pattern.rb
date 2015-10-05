require 'pp'
require 'stringio'

module Skylab::CSS_Convert
  module TestSupport end
  module TestSupport::CustomMatchers end
  module TestSupport::CustomMatchers::Functions
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
end

RSpec::Matchers.define :match_the_structure_pattern do |expected|
  extend ::Skylab::CSS_Convert::TestSupport::CustomMatchers::Functions
  match do |actual|
    expected.inspect == distilled_structure(actual).inspect
  end
  failure_message_for_should do |actual|
    act = ::PP.pp(distilled_structure(actual), ::StringIO.new).string
    exp = ::PP.pp(expected, ::StringIO.new).string
    dif = ::Rspec::Expectations.differ.diff_as_string(act, exp)
    "Sexp did not have the expected structure: #{dif}"
  end
end
