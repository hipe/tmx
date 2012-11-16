require_relative 'test-support'

describe ::Skylab::Porcelain::En do
  describe "oxford_commma" do
    include ::Skylab::Porcelain::En::Methods
    let(:subject) { oxford_comma arr }
    context(a = %w()) do
      let(:arr) { a }
      specify { should eql('') }
    end
    context(b = %w(eenie)) do
      let(:arr) { b }
      specify { should eql('eenie') }
    end
    context(c = %w(eenie meenie)) do
      let(:arr) { c }
      specify { should eql('eenie and meenie') }
    end
    context(d = %w(eenie meenie miney)) do
      let(:arr) { d }
      specify { should eql('eenie, meenie and miney') }
    end
    context(e = %w(eenie meenie miney moe)) do
      let(:arr) { e }
      specify { should eql('eenie, meenie, miney and moe') }
    end
  end
end
