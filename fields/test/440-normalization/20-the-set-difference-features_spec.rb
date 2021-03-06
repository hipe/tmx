require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] normalization - the set difference features" do

    # what we're calling the "set difference features" of normalization are
    # those that can implemented with simple set theory, namely:
    #
    #   - unexpected ("extra") arguments
    #   - missing required associations
    #
    # in a theoretical if not practical sense, we can define how we derive
    # these using the language of set theory: the "extra arguments" set can
    # be derived as the relative complement of the expected set with respect
    # to the actual set; and the missing required arguments can be derived
    # as the relative complement of the actual arguments set with respect to
    # the required arguments set.
    #
    #     required ⊆ associations
    #
    #     unexpected = actual \ associations
    #     missing = required \ actual
    #
    # in plain language, we can say that unexpected arguments are those
    # arguments that are in the actual argument set that are not in the set
    # of known associations.
    #
    # missing required arguments are those arguments in the set of required
    # (formal) arguments that are not in the actual arguments.
    #
    # ([#ze-027] is another place where we use set theory.)

    TS_[ self ]
    use :want_emission_fail_early

    it "loads" do
      subject_module_ || fail
    end

    # ==

    # (there was once a requirement that member arrays were frozen, but
    #  we no longer weigh things down with this code (#tombstone-A))

    # ==

    it "one extra - it stops on the first unrecognized \"primary\"" do

      # -
        any_object = ::Object.new

        _p = want_emission_fail_early_listener

        _normalize_by do |o|
          o.argument_array = [ :a, "one", :b, "two", :c, "three", :d, "four" ]
          o.member_array = [ :a, :c ]
          o.ivar_store = any_object
          o.listener = _p
        end

        want :error, :argument_error, :unknown_primary do |ev|
          _s_a = ev.express_into_under [], expression_agent
          want_these_lines_in_array_ _s_a do |y|
            y << "unrecognized member :b"
            y << "did you mean :c?"
          end
        end

        want_result false
      # -
    end

    it "set a nil explicitly works - all but one is nil" do

      # -
        any_object = ::Object.new

        _normalize_by do |o|
          o.argument_array = [ :a, "one", :b, nil, :c, "three" ]
          o.member_array = [ :a, :b, :c ]
          o.ivar_store = any_object
          # o.listener = _p
        end

        want_result true
      # -
    end

    it "if not all are present this is NOT a missing required" do

      # -
        any_object = ::Object.new

        _normalize_by do |o|
          o.argument_array = [ :a, "one", :c, "three" ]
          o.member_array = [ :a, :b, :c ]
          o.ivar_store = any_object
        end

        want_result true
      # -
    end

    it "you CAN effect a missing required checks with this configuration" do

      # -

        _p = want_emission_fail_early_listener

        any_object = ::Object.new

        _normalize_by do |o|
          o.argument_array = [ :a, "one", :c, "three" ]
          o.member_array = [ :a, :b, :c ]
          o.association_is_required_by = MONADIC_TRUTH_
          o.ivar_store = any_object
          o.listener = _p
        end

        want :error, :missing_required_attributes do |ev|
          _lines = ev.express_into_under [], expression_agent
          _lines == ["missing required member 'b'\n"] || fail
        end

        want_result false
      # -
    end

    # ==

    # (there was once a check that an argument array had a length of an even
    # number, but we no longer weigh things down with this check #tombstone-A)

    # ==

    it "use this configuration without an argument scanner for \"entity normalization\"" do

      # -

        _p = want_emission_fail_early_listener

        obj = ::Object.new

        obj.instance_variable_set :@a, true
        obj.instance_variable_set :@b, nil
        obj.instance_variable_set :@c, true

        _normalize_by do |o|
          o.member_array = [ :a, :b, :c ]
          o.association_is_required_by = MONADIC_TRUTH_
          o.ivar_store = obj
          o.listener = _p
        end

        ev = nil
        want :error, :missing_required_attributes do |ev_|
          ev = ev_
        end

        want_result false

        ev.reasons.to_a == [:b] || fail
      # -
    end

    # ==

    # (we used to allow that a listener could determine the result of the
    #  failed normalization; but this is now considered bad style #tombstone-A)

    # ==

    def _normalize_by
      call_by do
        subject_module_.call_by do |o|
          yield o
        end
      end
    end

    # ==

    def expression_agent
      _expag = Autoloader_.require_sidesystem( :Zerk )::No_deps[]::API_InterfaceExpressionAgent.instance
      _expag  # hi. #todo
    end

    def subject_module_
      Home_::Normalization
    end

    # ==
    # ==
  end
end
# #tombstone-A: this used to be the tests for [ba] "set"
