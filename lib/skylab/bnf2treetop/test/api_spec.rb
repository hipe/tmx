require_relative 'test-support'

describe "#{::Skylab::Bnf2Treetop::API}" do
  self::StreamSpy = ::Skylab::TestSupport::StreamSpy
  it 'the parameter "equals_terminal" lets you use different e.g. ::=' do
    one = translate(string: 'foo ::= bar', equals_terminal: '::=')
    two = translate(string: 'foo : bar', equals_terminal: ':')
    one.should eql(two)
    (15..50).should cover one.length
  end
  it 'the parameter "square" lets you use square brackets differently' do
    normal = translate(string: 'foo ::= [bar]')
    crazy  = translate(string: 'foo ::= [bar]', squares: true)
    normalize(normal).should eql('rule foo [bar] end')
    normalize(crazy).should  eql('rule foo (bar)? end')
  end
  def translate request
    request[:paystream] = ::StringIO.new
    # request[:paystream] = StreamSpy.standard.debug!('      FOO')

    request[:upstream] = ::StringIO.new(request.delete(:string))

    request[:infostream] # leave blank intentionally. should not get used.
    # request[:infostream] = StreamSpy.standard.debug!('      WTF!? - ')

    Skylab::Bnf2Treetop::API.translate(request) # t or nil
    request[:paystream].string
  end
  def normalize str
    str.gsub(/[[:space:]]+/, ' ').strip
  end
end
