require_relative '../../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] modalities - JSON - interpret" do

    TS_[ self ]
    use :future_expect
    use :common_model_and_methods

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

      it "when one is invalid - false" do

        _s = '{"first_name":"monsieur", "last_name":"gustav"}'

        future_expect_only :error, :expression, :no do | s_a |
          s_a.should eql [ "no: monsieur" ]
        end

        _expect_failure_against_string _s
      end

      it "when strange element in the structure - extra properties event" do

        future_expect :error, :extra_properties do | ev |

          _s = future_black_and_white ev

          _s.should eql "unrecognized element 'middle_initial' in 'someplace'"

        end

        _s = '{"first_name":"A", "last_name":"B", "middle_initial":7}'

        _expect_failure_against_string _s
      end

      it "when JSON object is empty" do

        future_expect_only :error, :empty_object do | ev |
          _s = future_black_and_white ev
          _s.should eql "for now, will not parse empty JSON object for 'someplace'"
        end

        _expect_failure_against_string '{}'
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

      it "when strange shape in structure (at level 1)" do

        future_expect_only :error, :strange_shape do | ev |

          _s = future_black_and_white ev

          _s.should eql "for 'simple_name' expected hash,#{
            } had '[]' (in 'someplace')"
        end

        _x = _from '{"nickname":"X", "simple_name":[]}', & fut_p
        _x.should eql false
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

    def _expect_failure_against_string s

      _x = _from s, & fut_p

      future_is_now

      _x.should eql false
    end

    def _from json, & oes_p

      oes_p ||= No_events_

      cls = const_ _which
      if cls.respond_to? :new_empty_for_test_
        new_empty = cls.new_empty_for_test_
      else
        raise ::NoMethodError, ___say( cls )
      end

      o = subject_::Modalities::JSON::Interpret.new( & oes_p )

      o.JSON = json
      o.ACS = new_empty

      o.prepend_more_specific_context_by do
        "in #{ code 'someplace' }"
      end

      _ok = o.execute
      _ok && new_empty
    end

    def ___say cls
      # honestly platform
      "undefined method `new_empty_for_test_` for #{ cls.name }"
    end
  end
end
# tests in here demonstrate #coverage-1