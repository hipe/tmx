require_relative '../../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] tenets - 7 B - the `using` modifer" do

    TS_[ self ]
    use :memoizer_methods

    it "works for multiple" do

      o = _new
      _ok = o.edit_entity(
        :using, :first,
        :using, :second,
        :effect, :list_of_things, :wazoozle
      )

      _ok.should eql :yep

      o.list_of_things.should eql [ :first, :second, :wazoozle ]
    end

    def _new
      _subject_class.new
    end

    shared_subject :_subject_class do

      class ACS_28_6_15_One

        def edit_entity * x_a, & x_p
          ACS_[].edit x_a, self, & x_p
        end

        def __list_of_things__component_association

          yield :can, :effect

          -> st do
            Common_::KnownKnown[ st.gets_one ]
          end
        end

        def __effect__component * many, qk, & _x_p

          many.push qk.value
          instance_variable_set qk.name.as_ivar, many
          :yep
        end

        attr_reader :list_of_things

        ACS_ = -> do
          Home_
        end

        self
      end
    end
  end
end
