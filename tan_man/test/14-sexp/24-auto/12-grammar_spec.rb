require_relative '../../test-support'

describe "[tm] sexp auto list pattern (grammar 12)", g: true do

  Skylab::TanMan::TestSupport[ self ]
  use :sexp_auto

  def self.it_trees_as arr, *tags
    it "it trees as #{arr.map{ |a| a.join(',') }.join(';')}", *tags do
      expect( result.content.stmts.map { |s| s.exprs } ).to eql arr
    end
  end

  using_grammar '12' do
    using_input '100-one-statement-one-expr' do
      it_unparses_losslessly
      it_trees_as [['aaaa']]
    end

    using_input '150-one-statement-two-exprs' do
      it_unparses_losslessly
      it_trees_as [['aaa3', 'bbb2']]
    end

    using_input '200-two-statements' do
      it_unparses_losslessly
      it_trees_as [['aaa'], ['bbb']]
    end

    using_input '300-two-statements-multiple-exprs' do
      it_unparses_losslessly
      it_trees_as [['aaa','aa','bb'], ['aa','bb'], ['a']]
    end
  end
end
