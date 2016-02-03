require_relative '../../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] modalities - JSON - interpretation intro" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event
    use :expect_root_ACS

    context "(flat structure)" do

      it "non-sparse one-level structure" do

        sn = _from '{"first_name":"Foo", "last_name":"Bar"}'
        sn.first_name.should eql 'Foo'
        sn.last_name.should eql 'Bar'
      end

      it "when one is null - validation must allow for this TODO change this behavior" do

        sn = _from '{"first_name":"Foo", "last_name":null}'
        sn.first_name.should eql 'Foo'
        sn.last_name.should be_nil
      end

      it "when one is not present - validation is not invoked, ivar not set" do

        sn = _from '{"last_name":"x"}'
        sn.instance_variables.should eql [ :@last_name ]
        sn.last_name.should eql "x"
      end

      context "when one is invalid - false" do

        shared_subject :root_ACS_state do

          _s = '{"first_name":"monsieur", "last_name":"gustav"}'
          _state_from _s
        end

        it "fails" do
          _fails
        end

        it "emits" do

          _be_this = be_emission :error, :expression, :no do |y|

            y.first.should be_include "can't be lowercase"
              # (the above sort of expr gets MUCH more attention in #23)
          end

          only_emission.should _be_this
        end
      end

      context "when strange element in the structure" do

        shared_subject :root_ACS_state do

          _s = '{"first_name":"A", "last_name":"B", "middle_initial":7}'
          _state_from _s
        end

        it "fails" do
          _fails
        end

        it "emits extra properties event" do

          _ = be_emission :error, :extra_properties do |ev|

            _s = black_and_white ev
            _s.should eql "unrecognized element 'middle_initial' in 'someplace'"
          end

          only_emission.should _
        end
      end

      context "when JSON object is empty" do

        shared_subject :root_ACS_state do
          _state_from '{}'
        end

        it "fails" do
          _fails
        end

        it "emits empty object error" do

          _ = be_emission :error, :empty_object do |ev|
            _s = black_and_white ev
            _s.should eql "for now, will not parse empty JSON object for 'someplace'"
          end

          only_emission.should _
        end
      end

      def _which
        :Simple_Name
      end
    end

    context "(some structure)" do

      it "normal case" do

        _s = '{"nickname":"NN","simple_name":{"first_name":"FN","last_name":"LN"}}'

        cn = _from _s
        cn.nickname.should eql 'NN'
        cn.simple_name.first_name.should eql 'FN'
        cn.simple_name.last_name.should eql 'LN'
      end

      context "when strange shape in structure (at level 1)" do

        shared_subject :root_ACS_state do

          _s = '{"nickname":"X", "simple_name":[]}'
          _state_from _s
        end

        it "fails" do
          _fails
        end

        it "emits - strange shape" do

          _ = be_emission :error, :strange_shape do | ev |

            _s = black_and_white ev

            _s.should eql "for 'simple_name' expected hash,#{
              } had '[]' (in 'someplace')"
          end

          only_emission.should _
        end
      end

      it "when null for compound component (component must participate)" do

        _s = '{"nickname":"NN", "simple_name":null}'

        cn = _from _s
        cn.nickname.should eql 'NN'
        cn.simple_name.first_name.should be_nil
        cn.simple_name.instance_variables.should eql []
      end

      def _which
        :Credits_Name
      end
    end

    def _state_from s

      _oes_p = event_log.handle_event_selectively
      x = _do_from _oes_p, s
      if x
        res = true  # fake it - does not matter
        o = x
      else
        res = x
        o = x
      end
      root_ACS_state_via res, o
    end

    def _from s
      _do_from No_events_, s
    end

    def _do_from oes_p, json

      cls = const_ _which
      new_empty = cls.new_cold_root_ACS_for_expect_root_ACS

      o = Home_::Modalities::JSON::Interpret.new( & oes_p )

      o.customization_structure_x = nil
      o.ACS = new_empty
      o.JSON = json

      o.prepend_more_specific_context_by do
        "in #{ code 'someplace' }"
      end

      _ok = o.execute
      _ok && new_empty
    end

    def _fails
      root_ACS_result.should be_common_result_for_failure
    end

    def expression_agent_for_expect_event
      clean_expag_
    end

    def subject_root_ACS_class
      Fixture_top_ACS_class[ :Class_01_Names ]
    end
  end
end
# tests in here demonstrate #coverage-1
