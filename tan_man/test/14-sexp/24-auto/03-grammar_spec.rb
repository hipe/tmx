require_relative '../../test-support'

describe "[tm] sexp auto list pattern (grammar 03)", g: true do

  Skylab::TanMan::TestSupport[ self ]
  use :sexp_auto

  using_grammar '03' do

    using_input 'alpha' do

      it "zoopie doopie floopie goopie" do
        result.agent.words.should eql(['one', 'two'])
        @result.target.words.should eql(['three'])
      end
    end
  end
end
