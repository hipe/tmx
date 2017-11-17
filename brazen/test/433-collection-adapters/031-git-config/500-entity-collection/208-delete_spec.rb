require_relative '../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] collection adapters - git config - entity collection - delete" do

    TS_[ self ]
    use :memoizer_methods
    use :collection_adapters_git_config_entity_collection

    context "delete not found (with listener)" do

      it "results in false" do
        _tuple.last == false || fail
      end

      it "this whine town has a semi-custom message" do

        _actual = _tuple.first

        want_these_lines_in_array_ _actual do |y|

          y << 'cannot delete foot wear "zeg zeg"'

          y << /\Anone of the 2 foot wears has this identifier in [^ ]+\.cfg\z/
        end
      end

      shared_subject :_tuple do

        spy = begin_emission_spy_

        spy.call_by do

          _x = footwear_facade_immutable_mutable_.delete 'zeg zeg', & spy.listener
          _x  # hi.
        end

        a = []
        spy.want :error, :expression, :component_not_found do |y|
          a.push y
        end

        a.push spy.execute_under self
        a
      end
    end

    context "delete normal" do

      # :#cov2.2

      it "the result is a (newly produced) entity, of what was deleted" do

        _tuple.first._natural_key_string_ == my_favorite_cons_ || fail
      end

      it "the um, deletion, like, worked" do

        # (we know this test is asserting something only because we
        # know how it works; meh.)

        st = _tuple.last.to_stream_of_all_such_entities

        _one = st.gets
        _two = st.gets

        _one._natural_key_string_ == "joggers" || fail
        _two.nil? || fail
      end

      shared_subject :_tuple do

        fac = build_new_mutable_footwear_facade_
        _wat = fac.delete my_favorite_cons_
        [ _wat, fac ]
      end
    end

    # ==
    # ==
  end
end
# #born years later, during massive refactor
