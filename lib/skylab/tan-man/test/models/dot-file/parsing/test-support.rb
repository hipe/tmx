require_relative '../test-support'

# (reference: http://solnic.eu/2014/01/14/custom-rspec-2-matchers.html)

if false
RSpec::Matchers.define :be_sexp do |expected|

  match do |actual|
    not
    if /\ASexps\z/ !~ (_ = actual.class.to_s.split('::')[-2]) then
      @message = "expected containing module to be Sexps,  had #{_}"
    elsif (_ = actual.class.expression) != expected
      @message = "expected expression to be #{expected.inspect} had #{_.inspect}"
    end
  end
  failure_message_for_should do |actual|
    @message or "unknown failure!"
  end
end
end

module Skylab::TanMan::TestSupport::Models::DotFile::Parsing

  Skylab::TanMan::TestSupport::Models::DotFile[ TS_ = self ]

  def self.extended mod
    regret_extended_notify mod
    mod.before(:all) { _my_before_all }
  end

  module ModuleMethods
    def it_unparses_losslessly(*tags)
      it 'unparses losslessly', *tags do
        result.unparse.should eql(input_string)
      end
    end
  end

  module InstanceMethods

    def module_with_subject_fixtures_node
      TS_
    end
  end
end
