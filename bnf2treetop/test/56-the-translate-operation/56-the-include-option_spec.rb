require_relative '../test-support'

describe "[bnf2tt] the translate operation - the `include` option" do

  Skylab::BNF2Treetop::TestSupport[ self ]
  use :API

  it 'includes that module in the output treetop grammar' do
    translate(string: 'foo ::= bar', include: 'X')
    expect( out.shift ).to be_include 'include X'
  end

  it 'possibly in a grammar, possibly multiple of them' do
    translate(string: 'foo ::= bar', include: ['X', 'Y'], grammar: 'A')
    out.shift # grammar
    expect( out.shift ).to be_include 'include X'
    expect( out.shift ).to be_include 'include Y'
  end
end
