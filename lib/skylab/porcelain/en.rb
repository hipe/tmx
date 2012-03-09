module Skylab
end

module Skylab::Porcelain
  module En
    def oxford_comma a, ult = ' or ', sep = ', '
      (hsh = Hash.new(sep))[a.length - 1] = ult
      [a.first, * (1..(a.length-1)).map { |i| [ hsh[i], a[i] ] }.flatten].join
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  require 'rspec/autorun'
  describe "oxford_commma" do
    include Skylab::Porcelain::En
    let(:subject) { oxford_comma arr }
    context (a = %w()) do
      let(:arr) { a }
      specify { should eql('') }
    end
    context (b = %w(eenie)) do
      let(:arr) { b }
      specify { should eql('eenie') }
    end
    context (c = %w(eenie meenie)) do
      let(:arr) { c }
      specify { should eql('eenie or meenie') }
    end
    context (d = %w(eenie meenie miney)) do
      let(:arr) { d }
      specify { should eql('eenie, meenie or miney') }
    end
    context (e = %w(eenie meenie miney moe)) do
      let(:arr) { e }
      specify { should eql('eenie, meenie, miney or moe') }
    end
  end
end

