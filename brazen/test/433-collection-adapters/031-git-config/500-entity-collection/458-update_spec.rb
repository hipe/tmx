require_relative '../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] collection adapters - git config - entity collection - update" do

    #   - an "update" (in contrast to a "create") is premised on the "entity"
    #     already "existing"; i.e the entity should have a corresponding
    #     section in the store (document) matched where the natural key of
    #     the entity is the subsection name of the section (and the section
    #     name is something like the model name).
    #
    #   - failure to find a corresponding section currently fails with an
    #     emission explaining the situation. (principle of least surprise
    #     might dicate that this should work like a failed dereference and
    #     fail hard, but who's to say this shouldn't act like the (vapor)
    #     "procure" instead?)
    #
    #   - otherwise (and we succeeded in finding the corresponding section),
    #     we "have" the corresponding section (document element).
    #
    #   - the entity proclaims (somehow) its list of attributes that are
    #     persisted ("the list"). (this starts out as a formal list of
    #     attribute names, not an actual list of attribute values.)
    #
    #   - by design we do not differentiate between an attribute being
    #     set to `nil` and an attribute not being set in the entity.
    #     (doing so has no benefit and would otherwise be annoying to
    #     bother distinguishing, because our store (also by design)
    #     doesn't accomodate explicit nils at all.)
    #
    #   as far as we can tell there are four categories that a formal
    #   field or potentially formal field can fall into:
    #
    #   - any assignment in the config but not in the list under this
    #     entity-section is an error ("extra")
    #
    #   - if an assignment is assigned in the config but it is effectively
    #     nil in the entity, this assignment (line) is removed. ("remove")
    #
    #   - otherwise (and the existing assignment has a corresponding value
    #     in the entity), such assignments have their values overwritten.
    #     (we don't bother checking for no change.) ("change")
    #
    #   - finally, those attributes with non-nil values in the entity
    #     that were not already processed by the above get added as
    #     assignments to the section. ("add")
    #
    # :#cov2.3

    TS_[ self ]
    use :memoizer_methods
    use :expect_emission_fail_early
    use :collection_adapters_git_config_entity_collection

    context "when you try to update a no ent" do

      it "results in false, emits `component_not_found`" do
        _tuple[1] == false || fail
      end

      it "explains" do

        _actual = _tuple.first

        expect_these_lines_in_array_ _actual do |y|

          y << 'cannot update: no existing foot wear "flip floppzz"'

          y << /\Anone of the 2 foot wears has this identifier in [^ ]+\.cfg\z/
        end
      end

      shared_subject :_tuple do

        _ent = footwear_class_.define do |o|
          o._natural_key_string_ = "flip floppzz"
        end

        _fac = footwear_facade_immutable_mutable_
        call_by do |p|
          _fac.update _ent, & p
        end

        a = []
        expect :error, :expression, :component_not_found do |y|
          a.push y
        end

        _x = execute
        a.push _x
        a
      end
    end

    context "updating this one guy complains because it has an attribute not in the list" do

      it "results in false" do
        _tuple[1] == false || fail
      end

      it "explains" do
        _actual = _tuple.first
        expect_these_lines_in_array_ _actual do |y|
          y << "cannot update: section in document has unrecognized assignment: 'flimbitty_bimbitty'"
        end
      end

      shared_subject :_tuple do

        _ent = footwear_class_.define do |o|
          o._natural_key_string_ = "joggers"
        end

        _fac = build_new_mutable_footwear_facade_  # (although this will ultimately fail, it begins to mutate first)
        call_by do |p|
          _fac.update _ent, & p
        end

        a = []
        expect :error, :expression, :unrecognized_assignments do |y|
          a.push y
        end

        _x = execute
        a.push _x
        a
      end
    end

    context "success" do

      it "result is true" do
        _tuple.last == true || fail
      end

      it "here's an assignment that was addded" do

        _hash_of_assignments_after[ :weight_in_ounces ].value == 12.5 || fail
      end

      it "here's an assignment that was removed" do

        _hash_of_assignments_after[ :date_of_purchase ] && fail
      end

      it "here's an assignment that was changed" do

        _hash_of_assignments_after[ :main_color ].value == "sky blue" || fail
      end

      it "event about value changed" do

        _actual = black_and_white_lines _tuple[1]

        expect_these_lines_in_array_ _actual do |y|
          y << 'value changed - ( main-color : "black" )'
        end
      end

      it "event about value added" do

        _actual = black_and_white_lines _tuple[2]

        expect_these_lines_in_array_ _actual do |y|
          y << 'added value - ( weight-in-ounces : 12.5 )'
        end
      end

      shared_subject :_hash_of_assignments_after do

        _fac = _tuple.first
        build_hash_of_assignments_after_for_ my_favorite_cons_, _fac
      end

      shared_subject :_tuple do

        a = []
        fac = build_new_mutable_footwear_facade_
        a.push fac

        _ent = footwear_class_.define do |o|

          o._natural_key_string_ = my_favorite_cons_

          o.weight_in_ounces = 12.5  # this becomes an added assignment

          # o.date_of_purchase = nil  # it should be the same to set this explicitly like so too

          o.main_color = "sky blue"  # this is a change to an existing assigmentn
        end

        call_by do |p|
          fac.update _ent, & p
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
