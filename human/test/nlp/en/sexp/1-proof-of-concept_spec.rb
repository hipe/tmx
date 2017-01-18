require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP EN Sexp - proof of concept" do  # (:#spot-2)

    TS_[ self ]

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
        _.should eql s
      end

      it "but normally empty lists express as writing nothing" do
        _ = _lib_node.express_into EMPTY_A_, [ :list, a ]
        _.should eql EMPTY_A_
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

        _o = _lib_node.expression_session_for :list, a, :alternation

        _ = _o.express_words_into []

        _.should eql [ "ada,", "grace,", "winifred", "or amy" ]
      end

      it "\"#{ s }\"" do
        _ = Common_::Oxford_or[ a ]
        _.should eql s
      end
    end

    it "`express_words_into_under`" do

      o = _lib_node.expression_session_for :list, %w( foo bar )

      o.expression_agent_method_for_saying_item :par

      _ = o.express_words_into_under [], common_expag_

      _.should eql [ "'foo'", "and 'bar'" ]
    end

    it "say, separator attributes" do
      o = _lib_node.expression_session_for :list, %w( foo bar baz )
      o.final_separator_sexp = [ :as_is, '--' ]
      o.separator_sexp = [ :as_is, '-' ]
      o.say.should eql 'foo-bar--baz'
    end

    it "curriable, stream for list, infer sexp from string.." do  # #todo

      o = _lib_node.expression_session_for :list

      o.final_separator = ' und '

      o.express_none_by { '[none]' }

      _ = o.with_list( Common_::THE_EMPTY_STREAM ).say

      _.should eql '[none]'

      _ = o.with_list( %w(a b) ).flush_to_word_string_stream___
      _ = _.to_a
      _.should eql [ "a", "und b" ]
    end

    # --

    def _flat a, s

      _ = _lib_node.express_into "", [ :list, a ]
      _.should eql s
    end

    def _words a, exp_a

      _o = _lib_node.expression_session_for :list, a

      _act_a = _o.express_words_into []

      _act_a.should eql exp_a
    end

    def _lib_node
      NLP_EN_Sexp_[]
    end
  end
end
# #tombstone: one of only 2 uses in the universe of `apply_experimental_specify_hack`
