# frozen_string_literal: true

require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[cm] no deps - operators injections" do

    TS_[ self ]
    use :memoizer_methods
    use :no_dependencies_zerk
    use :no_dependencies_zerk_features_injections

    # == 1

    context "against CLI head that looks like a primary" do

      context "parsing softly" do

        it "does not parse" do
          parsation_.result.nil? || fail  # :#Coverpoint1.1
        end

        it "does not advances scanner" do
          parsation_.token_scanner.head_as_is == "-xx-yy2" || fail
        end
      end

      shared_subject :parsation_ do
        against_CLI_arguments_ '-xx-yy2', 'zz'
        _flush_parsation
      end
    end

    # == 2

    context "against CLI head that looks like operator but isn't" do

      context "parsing softly" do

        it 'succeeds' do
          _match = parsation_.result
          _match.operator_symbol == :xx_yy3 || fail
        end

        it 'does NOT advance scanner' do
          _ = parsation_.token_scanner.head_as_is
          _ == 'xx-yy3' || fail
        end
      end

      context "but the lookup" do

        it "did not find" do
          findation_.result && fail
        end

        it "emits a `parse_error` (not a primary parse error)" do

          _emission.channel_symbol_array[2] == :parse_error || fail
        end

        it "first line - unrec" do
          _lines.first == "unrecognized operator: \"xx-yy3\"" || fail
        end

        it "second and final line - full splay" do

          a = _lines

          a.last =~ %r(\Aavailable (?:operat(?:ion|or)|action|node|feature)s: #{
            }xx, xx-yy1, he-ha and xx-yy2\z) || fail

          2 == a.length || fail
        end

        shared_subject :_lines do
          _emission.express_into_under [], expression_agent
        end

        shared_subject :_emission do
          flush_one_emission_via_findation_
        end
      end

      shared_subject :findation_ do
        _flush_findation
      end

      shared_subject :parsation_ do
        log = build_new_event_log_
        against_CLI_arguments_ 'xx-yy3', 'zz', & log.handle_event_selectively
        _flush_parsation log
      end
    end

    # == 3

    context "against CLI head that looks like operator and is" do

      context "parsing softly" do

        it "succeeds" do
          _ = parsation_.result
          _.operator_symbol == :xx_yy2 || fail
        end

        it 'did NOT advance scanner' do
          parsation_.token_scanner.head_as_is == 'xx-yy2' || fail
        end
      end

      context "and the lookup" do

        it "you can see the business value from the find result" do
          _ = findation_.result
          _.trueish_feature_value == :zzz || fail
        end

        it "you can reach the injector from the find result" do
          o = findation_
          inj_ref = o.omni.features.operators_injections.fetch o.result.injection_offset
          _inj = inj_ref.injection
          _inj.injection_symbol == :_INJECTION_2_ || fail
        end
      end

      shared_subject :findation_ do
        _flush_findation
      end

      shared_subject :parsation_ do
        against_CLI_arguments_ 'xx-yy2', 'zz'
        _flush_parsation
      end
    end

    # ==

    def _flush_parsation log=nil
      omni = dup_and_mutate_omni_
      _x = omni.argument_scanner_narrator.match_operator_shaped_token
      parsation_via_ _x, omni, log
    end

    def subject_omni_
      frozen_omni_one_
    end

    # == setup support

    def _flush_findation
      o = parsation_
      _x = o.omni.procure_operator
      findation_via_ _x, o.omni, o.log
    end

    def expression_agent
      expression_agent_for_nodeps_CLI_
    end

    # ==
    # ==
  end
end
