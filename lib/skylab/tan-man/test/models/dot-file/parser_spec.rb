require_relative 'parser/test-support'

describe "#{Skylab::TanMan::Models::DotFile::Parser}" do
  extend Skylab::TanMan::Models::DotFile::Parser::TestSupport
  str = 'digraph{}'
  context 'parsing an empty digraph' do
    context "one line no spaces (#{str.inspect})" do
      input str
      it 'yields a digrqaph document sexp' do
        sexp.should be_sexp(:document)
      end
      it 'unparses losslessly' do
        sexp.unparse.should eql(input)
      end
    end
  end
end
