require_relative '../../test-support'

describe "[bnf2tt] API feature - output comment" do

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
    out.shift.should eql('# this grammar was generated')
    out.shift.should be_include('rule foo')
  end
end
