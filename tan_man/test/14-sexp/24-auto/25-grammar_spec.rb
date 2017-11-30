require_relative '../../test-support'

describe "[tm] sexp auto list pattern (grammar 25)", g: true do

  Skylab::TanMan::TestSupport[ self ]
  use :sexp_auto

  using_grammar '25' do
    using_input '200-zero-items' do
      it_unparses_losslessly
      it "stmt_list is nil when you have zero items" do
        result = produce_result
        expect( result.stmt_list ).to eql nil
      end
    end

    using_input '300-one-item' do
      it_unparses_losslessly
      it_yields_the_stmts 'zerp'
    end

    using_input '305-one-item-no-space' do
      it_unparses_losslessly
      it_yields_the_stmts 'zerp'
    end

    using_input '310-one-item-one-semi' do
      it_unparses_losslessly
      it_yields_the_stmts 'zerp'
    end

    using_input '500-two-items' do
      it_unparses_losslessly
      it_yields_the_stmts 'zerp', 'nerp'
    end

    using_input '800-three-items-mixed' do
      it_unparses_losslessly
      it_yields_the_stmts 'zerp', 'nerp', 'zerp'
    end
  end
end
