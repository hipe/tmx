require_relative '../../test-support'

describe "[bnf2tt] API parameter - square" do

  Skylab::BNF2Treetop::TestSupport[ self ]
  use :API

  it 'includes that module in the output treetop grammar' do
    translate(string: 'foo ::= bar', include: 'X')
    out.shift.should be_include('include X')
  end

  it 'possibly in a grammar, possibly multiple of them' do
    translate(string: 'foo ::= bar', include: ['X', 'Y'], grammar: 'A')
    out.shift # grammar
    out.shift.should be_include('include X')
    out.shift.should be_include('include Y')
  end
end
