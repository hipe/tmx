require_relative '../../../../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] output adapters - q - v.c - copula assertion - escapes" do

    TS_[ self ]
    use :memoizer_methods
    use :output_adapters_quickie
    use :models_code_line

    it "loads" do
      copula_assertion_view_controller_class_
    end

    context "an insescapable escape sequence" do

      shared_subject :code_line_tuple_ do

        code_line_tuple_for_ "    #     Table[ [] ]  # => \"x\\y\"\n"
      end

      it "the result is an ordinary copula assertion" do

        _ = exactly_one_result_line_
        _ == "( Table[ [] ] ).should eql \"x\\y\"\n" || fail
      end

      it "emits an info (not error)"  do

        em = exactly_one_emission_

        em.channel_symbol_array == [ :info, :expression, :unsupported_escape_sequence ] || fail

        _ = em.expression_line_in_black_and_white
        _.include?(
          "in a double-quoted string, we don't know how to unescape \"y\" "
        ) || fail
      end
    end

    context "newlines OK" do

      shared_subject :code_line_tuple_ do

        code_line_tuple_for_ "  #     ice_cream  # => \"yay.\\n\"\n"
      end

      it "the result still expression still has the encoded newline in it." do

        _ = exactly_one_result_line_
        _.chop!
        _ == 'ice_cream.should eql "yay.\n"' || fail
      end

      it "no emissions" do
        emissions_.length.zero? || fail
      end
    end

    def copula_assertion_view_controller_class_
      output_adapter_module_::ViewControllers_::CopulaAssertion
    end
  end
end
