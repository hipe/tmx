require_relative 'test-support'

describe Skylab::Headless::NLP::EN::Methods do

  describe "[hl] NLP EN methods (oxford comma)" do

    include ::Skylab::Headless::NLP::EN::Methods

    ::Skylab::TestSupport::Quickie.apply_experimental_specify_hack self

    let :subject do
      oxford_comma arr
    end

    context(a = %w()) do
      let(:arr) { a }
      specify { should eql( nil ) }
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
