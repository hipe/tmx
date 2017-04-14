require_relative '../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] collection adapters - git config - entity collection - create" do

    #  - a "create" (in contrast to an "update") is premised on the "entity"
    #    *not* already existing in the store, as identified by the
    #    definition for identity as offered in the referent document.
    #
    #  - see the larger explanation in our sister test: #cov2.3

    TS_[ self ]
    use :memoizer_methods
    use :expect_emission_fail_early
    use :collection_adapters_git_config_entity_collection

    context "when you try to create one that already exists" do

      it "results in false, emits `entity_exists`" do
        _tuple[1] == false || fail
      end

      it "explains" do
        _actual = _tuple.first
        expect_these_lines_in_array_ _actual do |y|
          y << 'cannot create: foot wear "my favorite cons" already exists'
        end
      end

      shared_subject :_tuple do

        _ent = footwear_class_.define do |o|
          o._natural_key_string_ = my_favorite_cons_
        end

        _fac = footwear_facade_immutable_mutable_
        call_by do |p|
          _fac.create _ent, & p
        end

        a = []
        expect :error, :expression, :entity_exists do |y|
          a.push y
        end

        a.push execute
        a
      end
    end

    context "work it" do

      it "results in true" do

        _tuple.last == true || fail
      end

      it "the expected two assignments did write to the document" do

        h = _hash_of_assignments_after
        asmt1 = h[ :date_of_purchase ]
        asmt1 || fail
        asmt2 = h[ :weight_in_ounces ]
        asmt2 || fail
        asmt1.value_x == 123456 || fail
        asmt2.value_x == "heavy" || fail
      end

      it "the assignment that was nil did *not* write to the document" do

        _h = _hash_of_assignments_after
        _h[ :main_color ] && fail
      end

      it "emitted two emissions (one per assignment added), explain as expected" do

        ev1, ev2 = _tuple[ 1, 2 ]

        _actual1 = black_and_white ev1
        _actual2 = black_and_white ev2

        _actual1 == 'added value - ( date-of-purchase : 123456 )' || fail
        _actual2 == 'added value - ( weight-in-ounces : "heavy" )' || fail
      end

      new_bohemians = 'new "bohemians"'

      shared_subject :_hash_of_assignments_after do

        _fac = _tuple.first
        build_hash_of_assignments_after_for_ new_bohemians, _fac
      end

      shared_subject :_tuple do

        a = []
        fac = build_new_mutable_footwear_facade_
        a.push fac

        _ent = footwear_class_.define do |o|
          o._natural_key_string_ = new_bohemians
          o.date_of_purchase = 123456
          o.main_color = nil  # set it explicitly, just to prove the point
          o.weight_in_ounces = 'heavy'
        end

        call_by do |p|
          fac.create _ent, & p
        end

        expect :info, :related_to_assignment_change do |ev|
          a.push ev
        end

        expect :info, :related_to_assignment_change do |ev|
          a.push ev
        end

        a.push execute
        a
      end
    end

    def footwear_class_
      footwear_class_with_persistence_info_
    end

    # ==
    # ==
  end
end
# #born years later, during massive refactor
