require_relative '../../test-support'

module Skylab::Task::TestSupport

  describe "[ta] magnetics - models - token stream" do

    TS_[ self ]
    use :memoizer_methods
    use :magnetics

    _COMMON_ERROR = :unexpected_input

    context "minimal normative" do

      it "builds" do
        _tokenizer
      end

      it "normative" do

        _expect "foo, bar", "foo", "bar"
      end

      it "empty string - parses ok (no tokens)" do

        _expect EMPTY_S_
      end

      it "end on a separator" do

        _expect_error 'foo, bar, ', _COMMON_ERROR,
          /\Aexpecting word [^ ]+ at end of input\z/
      end

      it "on word with invalid chars" do

        _expect_error "foo, BAR", _COMMON_ERROR,
          /\Aexpecting word [^ ]+ at "BAR"\z/
      end

      shared_subject :_tokenizer do

        o = _subject_module.begin
        o.separator_regex = /, /
        o.word_regex = /[a-z]+/
        o.finish
      end
    end

    _COMMON_MESSAGE = 'expecting end expression (".ext") at ".exd"'

    context "expect certain endcaps" do

      it "normative input" do

        _expect 'foo-bar.ext', 'foo', 'bar'
      end

      it "only one word" do

        _expect 'fo.ext', 'fo'
      end

      it "weird extension" do

        _expect_error 'foo.exd', _COMMON_ERROR, _COMMON_MESSAGE
      end

      it "no extension" do

        _expect_error 'foo', _COMMON_ERROR,
          /\Aexpecting end expression [^ ]+ at end of input\z/
      end

      shared_subject :_tokenizer do

        o = _subject_module.begin
        o.separator_regex = /-/
        o.word_regex = /[a-z]+/
        o.end_token = '.ext'
        o.finish
      end
    end

    context "same but endcaps optional" do

      it "normative input (same)" do

        _expect 'foo-bar.ext', 'foo', 'bar'
      end

      it "only one word (same)" do

        _expect 'fo.ext', 'fo'
      end

      it "weird extension (same)" do

        _expect_error 'foo.exd', _COMMON_ERROR, _COMMON_MESSAGE
      end

      it "no extension - in contrast to the other, here it is ok" do

        _expect 'foo', 'foo'
      end

      it "no extension (two words) - ok" do

        _expect 'foo-bar', 'foo', 'bar'
      end

      shared_subject :_tokenizer do

        o = _subject_module.begin
        o.separator_regex = /-/
        o.word_regex = /[a-z]+/
        o.end_token = '.ext'
        o.end_expression_is_required = false
        o.finish
      end
    end



    def _expect_error input_string, error_category_sym, message_rx=nil

      _tok = _tokenizer

      i_a = nil ; message = nil

      st = _tok.token_stream_via_string input_string do | *i_a_, & ev_p |
        i_a = i_a_
        message = nil.instance_exec "", & ev_p
        :_never_see_
      end

      nil while st.gets  # exhaust the stream to hit the error

      if do_debug
        debug_IO.puts "#{ i_a.inspect } - #{ message.inspect }"
      end

      i_a.last == error_category_sym || fail

      if message_rx
        if message_rx.respond_to? :ascii_only?
          message == message_rx || fail
        else
          message =~ message_rx || fail
        end
      end
    end

    def _expect input_string, * expected_output_tokens

      _st = _tokenizer.token_stream_via_string input_string

      _a = _st.to_a

      _a == expected_output_tokens || fail
    end

    def _subject_module
      models_module_::TokenStream
    end
  end
end
