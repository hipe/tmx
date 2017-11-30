require_relative '../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP EN sexp - proof of concept" do  # :#spot1.2

    TS_[ self ]
    use :memoizer_methods

    it "node loads" do
      _lib_node
    end

    _word_mode = "(word mode)"

    context "none" do

      a = EMPTY_A_
      s = '[none]'

      it _word_mode do
        _words a, EMPTY_A_
      end

      it "([co]'s Oxford_and - #{ s.inspect })" do
        _ = Common_::Oxford_and[ a ]
        expect( _ ).to eql s
      end

      it "but normally empty lists express as writing nothing" do
        _ = _sexp_node.express_sexp_into___ EMPTY_A_, [ :list, a ]
        expect( _ ).to eql EMPTY_A_
      end
    end

    context "one" do

      a = %w(ada)
      s = 'ada'

      it _word_mode do
        _words a, a
      end

      it "\"#{ s }\"" do
        _flat a, s
      end
    end

    context "two" do

      a = %w( ada grace )
      s = 'ada and grace'

      it _word_mode do
        _words a, [ "ada", "and grace" ]
      end

      it "\"#{ s }\"" do
        _flat a, s
      end
    end

    context "three" do

      a = %w( ada grace winifred )
      s = 'ada, grace and winifred'

      it _word_mode do
        _words a, [ "ada,", "grace", "and winifred" ]
      end

      it "\"#{ s }\"" do
        _flat a, s
      end
    end

    context "four" do

      a = %w( ada grace winifred amy )
      s = 'ada, grace, winifred or amy'

      it _word_mode do

        _o = _sexp_node.expression_session_for :list, a, :alternation

        _ = _o.express_words_into []

        expect( _ ).to eql [ "ada,", "grace,", "winifred", "or amy" ]
      end

      it "\"#{ s }\"" do
        _ = Common_::Oxford_or[ a ]
        expect( _ ).to eql s
      end
    end

    it "`express_words_into_under`" do

      o = _sexp_node.expression_session_for :list, %w( foo bar )

      o.expression_agent_method_for_saying_item :par

      _ = o.express_words_into_under [], common_expag_

      expect( _ ).to eql [ "'foo'", "and 'bar'" ]
    end

    it "say, separator attributes" do
      o = _sexp_node.expression_session_for :list, %w( foo bar baz )
      o.final_separator_sexp = [ :as_is, '--' ]
      o.separator_sexp = [ :as_is, '-' ]
      expect( o.say ).to eql 'foo-bar--baz'
    end

    context "curriable, stream for list, infer sexp from string.." do

      it "against empty list" do

        _s = _expression.with_list( Common_::THE_EMPTY_STREAM ).say
        _s == '[none]' || fail
      end

      it "against some items - uses special guys and breaks into word string stream" do

        _expr = _expression.with_list %w( a b )
        _st = _expr.flush_to_word_string_stream___
        _a = _st.to_a
        _a == [ "a", "und b" ] || fail
      end

      shared_subject :_expression do

        _lib_node::Magnetics::List_via_Items.define do |o|

          o.final_separator = ' und '

          o.express_none_by { '[none]' }
        end
      end
    end

    # --

    def _flat a, s

      _ = _sexp_node.express_sexp_into___ "", [ :list, a ]
      expect( _ ).to eql s
    end

    def _words a, exp_a

      _o = _sexp_node.expression_session_for :list, a

      _act_a = _o.express_words_into []

      expect( _act_a ).to eql exp_a
    end

    def _sexp_node
      NLP_EN_.sexp_lib
    end

    def _lib_node
      NLP_EN_.lib
    end
  end
end
# #tombstone: one of only 2 uses in the universe of `apply_experimental_specify_hack`
