require_relative '../test-support'

describe "[bnf2tt] the translate operation - the `equals_terminal` option" do

  Skylab::BNF2Treetop::TestSupport[ self ]
  use :API

  it 'the parameter "equals_terminal" lets you use different e.g. ::=' do

    one = translate(string: 'foo ::= bar', equals_terminal: '::=')
    two = translate(string: 'foo : bar', equals_terminal: ':')
    expect( one ).to eql two
    expect( (15..50) ).to be_include one.length
  end
end
