require_relative 'test-support'

describe "#{::Skylab::Bnf2Treetop::API} feature \"modeline\"" do
  extend ::Skylab::Bnf2Treetop::API::Features::TestSupport
  it "lets you use any command-line options also as \"modeline\" params" do
    here = <<-HERE.unindent
      # bnf2treetop: set s e=\':\' g="Foo::BarBiff::Baz":
      foo : bar
    HERE
    translate(string: here, grammar:'Floo::FliffFlaff::Flazz')
    info.shift.should be_include(
      'squares equals_terminal=":" grammar="Foo::BarBiff::Baz"'
    )
    info.shift.should be_include('overridden')
    info.length.should eql(0)
    out.shift.should eql('module Floo::FliffFlaff')
  end
end
