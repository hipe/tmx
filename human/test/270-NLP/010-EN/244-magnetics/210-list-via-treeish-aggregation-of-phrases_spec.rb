require_relative '../../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] [..] expression sessions - list through treeish aggregation" do

    TS_[ self ]
    use :memoizer_methods

    context "artificial case" do

      shared_subject :_expression do

        o = _begin

        o.add_sexp [ :predicateish, :lemma, :be, :object_noun_phrase, "x" ]

        o.add_sexp [ :predicateish, :lemma, :be, :object_noun_phrase, "y" ]

        o.expression_via_finish
      end

      it "the result expression's category symbol is the same" do
        _expression.category_symbol_.should eql :predicateish
      end

      it "the result expression's verb lemma is the same" do
        _expression.lemma_symbol.should eql :be
      end

      it "the result expression's object noun phrase became the list" do
        x = _expression.object_noun_phrase
        x.category_symbol_.should eql :list

        a = x._read_only_array
        _one = a.fetch 0
        _two = a.fetch 1
        ivar = :@__word  # eww / joist
        _one.instance_variable_get( ivar ).should eql 'x'
        _two.instance_variable_get( ivar ).should eql 'y'
      end

      it "wahoo expression one" do

        _a = _jimmy_is
        _one_line( _a ).should match %r(\AJimmy is x and y\b)
      end
    end

    context "combine first \"big predicate\"" do

      shared_subject :_expression do

        o = _begin
        o.add_sexp _build_big_pred_with _sexp_1
        o.add_sexp _build_big_pred_with _sexp_2
        o.expression_via_finish
      end

      it "these things are normal" do
        _expression.lemma_symbol.should eql :be
        o = _expression.object_noun_phrase
        o.verb_lemma.should eql :miss
        oo = o.object_noun_phrase
        oo.lemma_symbol.should eql :property
        oo.modifier_word_list.send( :_s_a ).should eql [ 'required' ]
      end

      it "but note the constituency" do

        a = _expression.object_noun_phrase.object_noun_phrase.
          suffixed_proper_constituency._read_only_array

        _L = a.fetch 0
        _R = a.fetch 1

        :par == _L.send( :_m ) or fail
        :par_1 == _L.send( :_x ).as_variegated_symbol or fail
        :par_2 == _R.send( :_x ).as_variegated_symbol or fail
      end

      it "wahoo expression two" do

        _a = _jimmy_is
        _one_line( _a ).should match(
          %r(\AJimmy is missing required properties 'par-1' and 'par-2') )
      end
    end

    context "(singular)" do

      shared_subject :_expression do
        o = _begin
        o.add_sexp _build_big_pred_with [ :for_expag, :par, _PAR_1 ]
        o.expression_via_finish
      end

      it "(express three)" do

        _a = _jimmy_is
        _one_line( _a ).should match(
          %r(\AJimmy is missing required property 'par-1') )
      end

      it "(no subject three)" do
        _a = _when_wo_subject
        _a.should eql [ "missing required property 'par-1'\n" ]
      end
    end

    context "combine second \"big predicate\"" do

      shared_subject :_expression do

        o = _begin
        o.add_sexp _build_other_big_pred_with _sexp_1
        o.add_sexp _build_other_big_pred_with _sexp_2
        o.expression_via_finish
      end

      it "these things are normal" do

        o = _expression
        o.lemma_symbol.should eql :require

        oo = o.object_noun_phrase

        _wordlist = oo.suffixed_modifier_phrase
        _wordlist.send( :_s_a ).should eql %w( which failed to load )
      end

      it "but note the constituency" do

        _onp = _expression.object_noun_phrase

        _a = _onp.suffixed_proper_constituency._read_only_array

        _a.fetch( 0 ).send( :_x ).as_variegated_symbol.should eql :par_1
        _a.fetch( 1 ).send( :_x ).as_variegated_symbol.should eql :par_2
      end

      it "express four!" do

        _a = _jimmy_is
        _one_line( _a ).should match(
          %r(\AJimmy requires 'par-1' and 'par-2' which failed to load\b) )
      end

      it "(no subject four)" do

        _a = _when_wo_subject

        _one_line( _a ).should match(
          %r(\A'par-1' and 'par-2' which failed to load are required\b) )
      end
    end

    context "NOW watch what happens with a mix (closer to the catalyst case)" do

      shared_subject :_expression do

        o = _begin

        o.add_sexp _build_big_pred_with _sexp_1

        o.add_sexp _build_other_big_pred_with _sexp_1

        o.add_sexp _build_big_pred_with _sexp_2

        o.expression_via_finish
      end

      it "first of two (rough)" do
        _ = _first_of_two
        _.lemma_symbol.should eql :be
      end

      it "second of two (rough)" do
        _ = _second_of_two
        _.lemma_symbol.should eql :require
      end

      def _first_of_two
        _expression.read_only_array___.fetch 0
      end

      def _second_of_two
        _expression.read_only_array___.fetch 1
      end

      shared_subject :_lines do
        _jimmy_is
      end

      it "the three \"thoughts\" are compartmentalized into *two* lines" do
        2 == _lines.length or fail
      end

      it "the second line starts with \"also\" (NOT capitalized for now)" do
        _lines.fetch( 1 ).should match %r(\Aalso, )
      end

      it "both lines end with periods" do
        _both :__end_with_periods
      end

      it "both lines end with newlines" do
        _both :__end_with_newlines
      end

      it "content of first line looks good" do
        _lines.fetch( 0 ).should be_include(
          "Jimmy is missing required properties 'par-1' and 'par-2'"
        )
      end

      it "content of second line looks good" do
        _lines.fetch( 1 ).should be_include(
          "Jimmy requires 'par-1' which failed to load"
        )
      end

      def _both m
        p = send m
        a = _lines
        p[ a.fetch( 0 ) ]
        p[ a.fetch( 1 ) ]
      end

      def __end_with_periods
        rx = /\.$/
        -> x do
          rx =~ x or fail
        end
      end

      def __end_with_newlines
        rx = /\n\z/
        -> x do
          rx =~ x or fail
        end
      end
    end

    def _build_big_pred_with guy  # externally referenced as :[#053].

      [ :predicateish,
        :lemma, :be,
        :object_noun_phrase, [
          :gerund_phraseish,
          :verb_lemma, :miss,
          :object_noun_phrase, [
            :nounish,
            :lemma, :property,
            :modifier_word_list, %w( required ),
            :proper_noun, guy,
          ],
        ],
      ]
    end

    def _build_other_big_pred_with guy

      [ :predicateish,
        :lemma, :require,
        :object_noun_phrase, [
          :nounish,
          :suffixed_modifier_phrase, [ :word_list, %w( which failed to load ) ],
          :proper_noun, guy,
        ],
      ]
    end

    def _lines_via_statement_stream st
      expa = common_expag_
      a = []
      begin
        exp = st.gets
        exp or break
        exp.express_into_under a, expa
        redo
      end while nil
      a
    end

    # (to demonstrate that duping works, you hafta run the whole file..)

    o = nil
    define_method :_begin do
      if o
        o.dup
      else
        o = NLP_EN_Sexp_[].expression_session_for(
          :list, :through, :treeish_aggregation,
        )
        o
      end
    end

    dangerous_memoize :_sexp_1 do
      [ :for_expag, :par, _PAR_1 ]
    end

    dangerous_memoize :_sexp_2 do
      [ :for_expag, :par, _PAR_2 ]
    end

    dangerous_memoize :_PAR_1 do
      _par :par_1
    end

    dangerous_memoize :_PAR_2 do
      _par :par_2
    end

    def _par sym
      Common_::Name.via_variegated_symbol sym
    end

    def _when_wo_subject

      _exp = _expression
      _st = _exp.to_statementish_stream_for_no_subject
      _lines_via_statement_stream _st
    end

    _JIMMY = 'Jimmy'

    define_method :_jimmy_is do

      _exp = _expression

      _st = _exp.to_statementish_stream_for_subject(
        :nounish, :proper_noun, _JIMMY )

      _lines_via_statement_stream _st
    end

    def _one_line a
      1 == a.length or fail
      a.fetch 0
    end
  end
end
