require_relative '../../test-support'

describe "[tm] sexp auto list pattern (grammar 06)", g: true do

  Skylab::TanMan::TestSupport[ self ]
  use :sexp_auto

  using_grammar '60-content-pattern' do
    using_input '300.dot' do
      it_unparses_losslessly
      it 'gets the content_text_value of different kind of comments' do
        a = result.comments
        a.map { |x| x.class.expression }.should eql(
          [:c_style_comment, :shell_style_comment, :c_style_comment]
        )
        a[0].content_text_value.should eql(' comment 1 ')
        a[1].content_text_value.should eql(' comment 2')
        a[2].content_text_value.should eql(" comment 3\n   on two lines ")
      end
    end
  end
end
