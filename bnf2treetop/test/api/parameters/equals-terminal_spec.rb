require_relative 'test-support'

describe "[bnf2tt] API parameter - `equals_terminal`" do

  extend ::Skylab::Bnf2Treetop::API::Parameters::TestSupport

  it 'the parameter "equals_terminal" lets you use different e.g. ::=' do

    one = translate(string: 'foo ::= bar', equals_terminal: '::=')
    two = translate(string: 'foo : bar', equals_terminal: ':')
    one.should eql(two)
    (15..50).should be_include one.length
  end
end
