require_relative 'test-support'

describe "#{::Skylab::Bnf2Treetop::API} parameter \"square\"" do
  extend ::Skylab::Bnf2Treetop::API::Parameters::TestSupport
  it 'the parameter "square" lets you use square brackets differently' do
    normal = translate(string: 'foo ::= [bar]')
    crazy  = translate(string: 'foo ::= [bar]', squares: true)
    normalize(normal).should eql('rule foo [bar] end')
    normalize(crazy).should  eql('rule foo bar? end')
  end
  def normalize str
    str.gsub(/[[:space:]]+/, ' ').strip
  end
end
