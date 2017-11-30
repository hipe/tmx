require_relative '../test-support'

module Skylab::Arc::TestSupport

  describe "[arc] JSON magnetics - ACS via JSON" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event
    use :want_root_ACS
    use :JSON_magnetics_lite

    context "(flat structure)" do

      it "non-sparse one-level structure" do

        sn = _from '{"first_name":"Foo", "last_name":"Bar"}'
        expect( sn.first_name ).to eql 'Foo'
        expect( sn.last_name ).to eql 'Bar'
      end

      it "when one is null - validation must allow for this TODO change this behavior" do

        sn = _from '{"first_name":"Foo", "last_name":null}'
        expect( sn.first_name ).to eql 'Foo'
        expect( sn.last_name ).to be_nil
      end

      it "when one is not present - validation is not invoked, ivar not set" do

        sn = _from '{"last_name":"x"}'
        sn.instance_variable_defined?( :@last_name ) or fail
        expect( sn.last_name ).to eql "x"
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

            expect( y.first ).to be_include "can't be lowercase"
              # (the above sort of expr gets MUCH more attention in #23)
          end

          expect( only_emission ).to _be_this
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

          _ = be_emission :error, :unrecognized_argument do |ev|

            _s = black_and_white ev
            expect( _s ).to eql 'unrecognized element \'middle_initial\' in "someplace"'
          end

          expect( only_emission ).to _
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
            expect( _s ).to eql 'for now, will not parse empty JSON object for "someplace"'
          end

          expect( only_emission ).to _
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
        expect( cn.nickname ).to eql 'NN'
        expect( cn.simple_name.first_name ).to eql 'FN'
        expect( cn.simple_name.last_name ).to eql 'LN'
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

            expect( _s ).to eql "for \"simple_name\" expected hash,#{
              } had < a Array > (in \"someplace\")"
          end

          expect( only_emission ).to _
        end
      end

      it "when null for compound component (component must participate)" do

        _s = '{"nickname":"NN", "simple_name":null}'

        cn = _from _s
        expect( cn.nickname ).to eql 'NN'
        expect( cn.simple_name.first_name ).to be_nil
        expect( cn.simple_name.instance_variables ).to eql []
      end

      def _which
        :Credits_Name
      end
    end

    def _state_from s

      _p = event_log.handle_event_selectively
      x = _do_from _p, s
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

    def _do_from p, json

      cls = const_ _which
      new_empty = cls.new_cold_root_ACS_for_want_root_ACS

      o = subject_magnetics_module_::ACS_via_JSON.new( & p )

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
      expect( root_ACS_result ).to be_common_result_for_failure
    end

    def expression_agent_for_want_emission
      expag_for_cleanliness_
    end

    def subject_root_ACS_class
      Fixture_top_ACS_class[ :Class_01_Names ]
    end
  end
end
# tests in here demonstrate #coverage-1
