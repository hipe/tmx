require_relative '../test-support'

describe "[bnf2tt] the translate operation - comments are passed through" do

  Skylab::BNF2Treetop::TestSupport[ self ]
  use :API

  it "passes-thru comments with the VERY EXPERIMENTAL #{
    }(output \"...\") syntax" do

    here = <<-HERE.unindent
      # this file is fed into bnf2treetop which gives (output "..") special meaning
      # (output "this grammar was generated")
      # the above line will pass thru, this line will not

      foo ::= bar
    HERE
    translate(string: here)
    expect( out.shift ).to eql '# this grammar was generated'
    expect( out.shift ).to be_include 'rule foo'
  end
end
