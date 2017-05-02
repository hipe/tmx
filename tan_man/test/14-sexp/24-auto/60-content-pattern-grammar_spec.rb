require_relative '../../test-support'

describe "[tm] sexp auto list pattern (grammar 06)", g: true do

  Skylab::TanMan::TestSupport[ self ]
  use :sexp_auto

  using_grammar '60-content-pattern' do

    using_input '300.dot' do

      it_unparses_losslessly

      it 'gets the content_text_value of different kind of comments' do

        a = result.comments

        _these = a.map do |sx|
          sx.class.expression_symbol
        end

        _these == (
          [:c_style_comment, :shell_style_comment, :c_style_comment]
        ) || fail

        a[0].content_text_value == " comment 1 " || fail
        a[1].content_text_value == " comment 2" || fail
        a[2].content_text_value == " comment 3\n   on two lines " || fail
      end
    end
  end
end
