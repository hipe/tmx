require_relative '../test-support'

describe "[bnf2tt] the translate operation - the modeline feature" do

  Skylab::BNF2Treetop::TestSupport[ self ]
  use :API

  it "lets you use any command-line options also as \"modeline\" params" do

    here = <<-HERE.unindent
      # bnf2treetop: set s e=\':\' g="Foo::BarBiff::Baz":
      foo : bar
    HERE

    translate(string: here, grammar:'Floo::FliffFlaff::Flazz')

    expect( info.shift ).to be_include(
      'squares equals_terminal=":" grammar="Foo::BarBiff::Baz"'
    )

    expect( info.shift ).to be_include 'overridden'
    expect( info.length ).to eql 0
    expect( out.shift ).to eql 'module Floo::FliffFlaff'
  end
end
