require_relative '../test-support'

module Skylab::Treemap::TestSupport

  describe "[tr] magnetics - quantity tree via node - NOTE - IN FLUX.." do

    # we don't yet know the requirements

    TS_[ self ]
    use :memoizer_methods
    use :common_magnets_and_models

    context "tree with depth (groceries) - WHEN NO WHITESPACE" do

      it "builds" do
        _subject || fail
      end

      _DERIVED_TOTAL = 12

      it "rootmost branch node has a total reflecting the deep, derived total" do
        _subject.total == _DERIVED_TOTAL || fail
      end

      it "we see that it has no declared total" do
        _subject.declared_total.nil? || fail
      end

      it "`main_quantity` give you the derived total" do
        _subject.main_quantity == _DERIVED_TOTAL || fail
      end

      def _subject
        groceries_A_quantity_tree
      end
    end
  end
end
