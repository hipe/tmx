require_relative 'test-support'

describe "#{::Skylab::TanMan::Sexp::Auto} list pattern (grammar 03)" do
  extend ::Skylab::TanMan::Sexp::Auto::TestSupport

  using_grammar '03' do
    using_input 'alpha' do
      it "zoopie doopie floopie goopie" do
        result.agent.words.should eql(['one', 'two'])
        result.target.words.should eql(['three'])
      end
    end
  end
end
