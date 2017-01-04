require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] argument scanner - [..] via multiple entities" do

    # :#a.s-coverpoint-1

    TS_[ self ]
    use :memoizer_methods
    use :argument_scanner

    it "loads" do
      _subject_module
    end

    context "the successful parse.." do

      it "builds" do
        _scenario_tuple.compound_branch
      end

      it "the parse works" do

        _o = _scenario_tuple_after_parse_result
        _o.parse_result == true || fail
      end

      it "those attributes that were unique to the entities were written" do

        o = _scenario_tuple_after_parse_result
        br = o.operation_A
        pb = o.operation_B
        # --
        br.sprouted == true || fail
        pb.crunchy == true || fail
        pb.brand_name == "Zoozie" || fail
      end

      it "for those attributes not unique to the entities, first match won only because not fuzzy" do

        o = _scenario_tuple_after_parse_result
        br = o.operation_A
        pb = o.operation_B
        # --
        br.organic.nil? || fail
        pb.organic == true || fail
      end

      shared_subject :_scenario_tuple_after_parse_result do

        __effect_the_parse_step _scenario_tuple
      end

      dangerous_memoize :_scenario_tuple do

        _scenario_tuple_via_tokens :sprouted, :crunchy, :brand_name, "Zoozie", :organic
      end
    end

    def __effect_the_parse_step o

      # (be careful - you are using the same memoized scenario pieces
      # from elsewhere, but taking them a step further. because this mutates
      # the argument scanner as well as the value store, it must only be
      # called once per such scenario.)

      _ok = o.compound_branch.parse_all_from o.argument_scanner

      o.parse_result = _ok

      o
    end

    def _scenario_tuple_via_tokens * x_a

      argument_scanner = Home_::API::ArgumentScanner.via_array x_a, & Expect_no_emission_

      bread_op = ts_::Bread.new argument_scanner

      peanut_butter_op = ts_::PeanutButter.new argument_scanner

      pb_ob = peanut_butter_op.operator_branch

      _real_br_op = bread_op.operator_branch

      use_br_ob = lib_::OperatorBranch_via_OtherBranch.define _real_br_op do |o|
        o.not :baking_temp, :organic
      end

      _subj = _subject_module.define do |o|
        o.add_entity_and_operator_branch bread_op, use_br_ob
        o.add_entity_and_operator_branch peanut_butter_op, pb_ob
      end

      _classes  # load them

      o = X_as_obvob_Scenario.new
      o.operation_A = bread_op
      o.operation_B = peanut_butter_op
      o.argument_scanner = argument_scanner
      o.compound_branch = _subj
      o
    end

    memoize :_classes do

      X_as_obvob_Scenario = ::Struct.new(
        :parse_result,
        :argument_scanner,
        :compound_branch,
        :operation_A,
        :operation_B,
      )

      NIL
    end

    def _subject_module
      Home_::ArgumentScanner::OperatorBranch_via_MultipleEntities
    end
  end
end
