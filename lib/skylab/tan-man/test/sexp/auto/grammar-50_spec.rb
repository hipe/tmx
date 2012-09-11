require_relative 'test-support'

describe "#{::Skylab::TanMan::Sexp::Auto} list pattern (grammar 50)" do
  extend ::Skylab::TanMan::Sexp::Auto::TestSupport

  using_grammar '50' do
    using_input '100-one-arc.dot' do
      it_should_unparse_losslessly
    end
    using_input '110-two-arcs.dot' do
      it_should_unparse_losslessly
    end
  end
end
