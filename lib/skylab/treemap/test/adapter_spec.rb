require_relative '../../test-support/test-support'
require_relative '../api'

describe "#{Skylab::Treemap::Adapter::NameFunction}::EXTNAME_RE" do
  let(:re) { Skylab::Treemap::Adapter::NameFunction::EXTNAME_RE }
  let(:match_data) { re.match(input) }
  let(:subject) { md = match_data || {} ; [md[:stem], md[:extname]] }
  def self.this input, output, *rest
    context(input.inspect) do
      let(:input) { input }
      specify { should eql(output) }
    end
  end
  context "matches the set of all strings" do
    this '', ['', nil]
    this '.', ['', '.']
    this '..', ['.','.']
    this '...', ['..','.']
    this '.abc', ['', '.abc']
    this 'abc.', ['abc', '.']
    this 'foo', ['foo', nil]
    this 'foo.bar', ['foo', '.bar']
    this 'foo.bar.baz', ['foo.bar', '.baz']
  end
end

