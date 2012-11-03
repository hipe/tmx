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

module Skylab::TanMan::Models::DotFile::Parser::TestSupport
  def self.extended mod
    mod.module_eval do
      extend ModuleMethods
      include InstanceMethods
      before(:all) { _my_before_all }
    end
  end
  module ModuleMethods
    include ::Skylab::TanMan::Models::DotFile::TestSupport::ModuleMethods

    def it_unparses_losslessly(*tags)
      it 'unparses losslessly', *tags do
        result.unparse.should eql(input_string)
      end
    end
  end
  module InstanceMethods
    extend ::Skylab::TanMan::TestSupport::InstanceMethodsModuleMethods
    include ::Skylab::TanMan::Models::DotFile::TestSupport::InstanceMethods
    let(:_parser_dir_path) { ::File.expand_path('..', __FILE__) }
  end
end
