require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] argument scanner - compounded primaries" do

    TS_[ self ]
    use :memoizer_methods

    it "loads" do
      _subject_module
    end

    context "the successful parse.." do

      it "builds" do
        _scenario_tuple.compounded_primaries
      end

      it "the parse works" do

        _o = _scenario_tuple_after_parse_result
        _o.parse_result == true
      end

      it "because you chose a receipient for a shared name, it works" do

        o = _scenario_tuple_after_parse_result
        br = o.operation_A
        pb = o.operation_B
        # --
        br.organic.nil? || fail
        pb.organic == true || fail
      end

      it "the other things worked" do

        o = _scenario_tuple_after_parse_result
        br = o.operation_A
        pb = o.operation_B
        # --
        br.sprouted == true || fail
        pb.crunchy == true || fail
        pb.brand_name == "Zoozie" || fail
      end

      shared_subject :_scenario_tuple_after_parse_result do

        __write_parse_result_into _scenario_tuple
      end

      dangerous_memoize :_scenario_tuple do

        _scenario_tuple_via_tokens :sprouted, :crunchy, :brand_name, "Zoozie", :organic
      end
    end

    def __write_parse_result_into o

      _argument_scanner = o.argument_scanner
      _compounded_primaries = o.compounded_primaries

      _ok = _compounded_primaries.parse_against _argument_scanner
      o.parse_result = _ok
      o
    end

    def _scenario_tuple_via_tokens * x_a

      _classes  # load them

      this = -> * _ do
        TS_._WEEEEE
      end

      argument_scanner = Home_::API::ArgumentScanner.via_array x_a, & this

      bread_op = X_as_cp_Bread.new argument_scanner
      peanut_butter_op = X_as_cp_PeanutButter.new argument_scanner

      _subj = _subject_module.define do |defn|

        defn.add_operation bread_op do |o|
          o.not :baking_temp, :organic
        end

        defn.add_operation peanut_butter_op
      end

      o = X_as_cp_Scenario.new
      o.operation_A = bread_op
      o.operation_B = peanut_butter_op
      o.argument_scanner = argument_scanner
      o.compounded_primaries = _subj
      o
    end

    memoize :_classes do

      X_as_cp_Same = ::Class.new

      class X_as_cp_Bread < X_as_cp_Same

        PRIMARIES = {
          baking_temp: :one_argument,
          organic: :boolean,
          sprouted: :boolean,
        }

        attr_reader(
          :organic,
          :sprouted,
        )
      end

      class X_as_cp_PeanutButter < X_as_cp_Same

        PRIMARIES = {
          brand_name: :one_argument,
          crunchy: :boolean,
          organic: :boolean,
        }

        attr_reader(
          :brand_name,
          :crunchy,
          :organic,
        )
      end

      class X_as_cp_Same

        def initialize fake_as
          @argument_scanner = fake_as
        end

        def syntax_front
          @___sf ||= __build_syntax_front
        end

        def __build_syntax_front
          ::Skylab::TestSupport::Slowie::Models_::HashBasedSyntax.new(
            @argument_scanner, self.class::PRIMARIES, self )
        end

        def parse_present_primary_for_syntax_front_via_branch_hash_value k
          send TYPES___.fetch k
        end

        TYPES___ = {
          boolean: :__parse_boolean,
          one_argument: :__parse_one_argument,
        }

        def __parse_boolean
          _ivar = _parse_ivar
          instance_variable_set _ivar, true
          ACHIEVED_
        end

        def __parse_one_argument
          _ivar = _parse_ivar
          _kn = @argument_scanner.parse_primary_value
          instance_variable_set _ivar, _kn.value_x
          ACHIEVED_
        end

        def _parse_ivar
          _sym = :"@#{ @argument_scanner.current_primary_symbol }"
          @argument_scanner.advance_one
          _sym
        end
      end

      X_as_cp_Scenario = ::Struct.new(
        :parse_result,
        :argument_scanner,
        :compounded_primaries,
        :operation_A,
        :operation_B,
      )

      NIL
    end

    def _subject_module
      Home_::ArgumentScanner::CompoundedPrimaries
    end
  end
end
