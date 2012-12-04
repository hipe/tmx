require_relative '../test-support'

# (reference: http://solnic.eu/2014/01/14/custom-rspec-2-matchers.html)
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

module Skylab::TanMan::TestSupport::Models::DotFile::Parser
  Skylab::TanMan::TestSupport::Models::DotFile[ Parser = self ]

  def self.extended mod
    _regret_extended mod
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
    let(:_parser_dir_path) { Parser.dir_path }
  end
end
