require_relative '../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] collection adapters - git config - entity collection - retrieve" do

    TS_[ self ]
    use :memoizer_methods
    use :collection_adapters_git_config_entity_collection

    it "dereference" do

      _facade.dereference( my_favorite_cons_ )._natural_key_string_ == my_favorite_cons_ || fail
    end

    it "lookup softly (yes)" do

      _facade.lookup_softly( joggers_ )._natural_key_string_ == joggers_ || fail
    end

    it "lookup softly (no)" do

      _facade.lookup_softly( 'crocks' ).nil? || fail
    end

    it "procure (yes)" do

      _facade.procure( joggers_ )._natural_key_string_ == joggers_ || fail
    end

    context "procure (emit emission when not found) (no)" do

      it "results in false" do
        _tuple.last == false || fail
      end

      it "first line of emission talks about not found (humanizes model name)" do
        _actual = _tuple.first.first
        _actual == 'foot wear "zug zug" not found' || fail
      end

      it "second line of emission talks about context" do
        _actual = _tuple.first.last
        _actual =~ /\Anone of the 2 foot wears has this identifier in [^ ]+\.cfg\z/ || fail
      end

      shared_subject :_tuple do

        spy = begin_emission_spy_

        spy.call_by do

          _x = _facade.procure 'zug zug', & spy.listener
          _x  # hi.
        end

        a = []
        spy.want :error, :expression, :component_not_found do |y|
          a.push y
        end

        _x = spy.execute_under self
        a.push _x

        a
      end
    end

    context "procure (emit emission when not found) (no) (again)" do

      it "different explanation because no such entities at all in collection" do

        _actual = _tuple.first

        want_these_lines_in_array_ _actual do |y|
          y << 'jawn jawn "zeg zeg" not found'
          y << /\Anone of the 4 sections was about jawn jawns in [^ ]+\.cfg\z/
        end
      end

      shared_subject :_tuple do

        spy = begin_emission_spy_

        spy.call_by do

          _x = jawn_jawn_facade_.procure 'zeg zeg', & spy.listener
          _x  # hi.
        end

        a = []
        spy.want :error, :expression, :component_not_found do |y|
          a.push y
        end

        _x = spy.execute_under self
        _x == false || fail

        a
      end
    end

    def _facade
      footwear_facade_immutable_
    end

    # ==
    # ==
  end
end
# #born years later, during massive refactor
