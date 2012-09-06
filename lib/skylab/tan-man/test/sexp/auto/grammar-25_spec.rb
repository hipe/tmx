require_relative 'test-support'

describe "#{::Skylab::TanMan::Sexp::Auto} list pattern (grammar 25)" do
  extend ::Skylab::TanMan::Sexp::Auto::TestSupport

  using_grammar '25' do
    using_input '500-two-items' do
      it_should_unparse_losslessly
      it "should let you iterate thru the items transparently" # e4
    end
  end
end
