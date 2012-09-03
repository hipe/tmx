require_relative 'parser/test-support'

describe "#{Skylab::TanMan::Models::DotFile::Parser}" do
  extend Skylab::TanMan::Models::DotFile::Parser::TestSupport
  context 'parsing an empty digraph' do
    def self.it_parses(*tags)
      it 'yields a digraph document sexp', *tags do
        sexp.should be_sexp(:graph)
      end
    end
    def self.it_unparses(*tags)
      it 'unparses losslessly', *tags do
        sexp.unparse.should eql(input)
      end
    end
    str = 'digraph{}'
    context "one line no spaces (#{str.inspect})" do
      input str
      it_parses
      it_unparses
    end
    str = " \n\n \tdigraph { \t } \n "
    context "multiple lines lots of whitespace" do
      input str
      it_parses
      it_unparses
    end
  end
end
