require_relative '../test-support'

module Skylab::Human::TestSupport

  describe "[hu] sexp - expression collection" do

    TS_[ self ]
    use :memoizer_methods

    it "camel case for business parts" do
      _ 'gerund-phraseish', :GerundPhraseish
    end

    it "`through` and `of` are special" do
      _ 'list-through-columnar-aggregation-of-statementishes',
        :List_through_ColumnarAggregation_of_Statementishes
    end

    it "`when` at beginning is special" do
      _ 'when-object-and-subject', :When_Object_and_Subject
    end

    def _ head, const
      _const = Home_::Sexp::Const_via_Tokens_.via_head head
      _const == const || fail
    end
  end
end
