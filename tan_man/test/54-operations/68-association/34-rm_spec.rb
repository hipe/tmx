require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - association delete" do

    TS_[ self ]
    use :memoizer_methods
    use :want_CLI_or_API
    use :models_association

# (1/N)
    context "remove when first node not found (no stmt_list)" do  # :#cov2.5

      it "fails" do
        fails_
      end

      it "dedicated emission" do
        _actual = black_and_white tuple_.event_of_significance
        _actual =~ /\Ano stmt list - / || fail  # (the whole string is repeated)
      end

      shared_subject :tuple_ do
        will_remove_association_foo_bar_from_ "digraph {\n}\n"
        tuple_for_dedicated_emission_and_failure_ :no_stmt_list
      end
    end

# (2/N)
    context "remove when first node not found" do

      it "fails" do
        fails_
      end

      it "dedicated emission" do
        want_message_ 'node not found - "foo"'
      end

      shared_subject :tuple_ do
        will_remove_association_foo_bar_from_ "digraph {\nbaz}\n"
        tuple_for_dedicated_emission_and_failure_ :node_not_found
      end
    end

# (3/N)
    context "remove when 2nd node not found" do

      it "fails" do
        fails_
      end

      it "dedicated emission" do
        want_message_ 'node not found - "bar"' || fail
      end

      shared_subject :tuple_ do
        will_remove_association_foo_bar_from_ "digraph {\n foo [ label = \"foo\"]\n }\n"
        tuple_for_dedicated_emission_and_failure_ :node_not_found
      end
    end

# (4/N)
    context "remove when not associated" do

      it "fails" do
        fails_
      end

      it "dedicated emission" do
        want_message_ "association not found - 'foo -> bar'"
      end

      shared_subject :tuple_ do
        will_remove_association_foo_bar_from_ "digraph {\n foo\nbar\nbar -> foo\n }\n"
        tuple_for_dedicated_emission_and_failure_ :component_not_found
      end
    end

# (5/N)
    context "remove when associated" do

      it "event has association deleted" do
        event_.association.edge_stmt.unparse == "foo -> bar" || fail
      end

      it "final output" do
        final_output_ == "digraph {\n foo\nbar\n}\n" || fail
      end

      shared_subject :tuple_ do

        will_remove_association_foo_bar_from_ "digraph {\n foo\nbar\nfoo -> bar\n }\n"

        tuple_for_money_town_ do |tup|  # ick/meh

          want :info, :deleted_association do |ev|
            tup.event_of_significance = ev
          end

          want :success, :wrote_resource
        end
      end
    end

    # ==
    # ==
  end
end
# #history-A: full rewrite during ween off [br]-era
