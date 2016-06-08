require_relative '../../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] tenets -  7 C - the `if` modifer" do

    TS_[ self ]
    use :memoizer_methods

    it "does yes when yes" do

      o = _new

      _ok = o.edit_entity(
        :if, :color_starts_with_g,
        :add, :color, :green,
      )

      _ok.should eql [ :last_delivery_result, :green ]
      o._a.should eql [ :green ]
    end

    it "does no when no" do

      o = _new

      _ok = o.edit_entity(
        :if, :color_starts_with_g,
        :add, :color, :red,
      )

      _ok.should eql :welff_nothing_happened
      o._a.length.should be_zero
    end

    it "does the second of two" do

      o = _new

      _ok = o.edit_entity(

        :if, :color_starts_with_g,
        :add, :color, :red,
        :if, :color_starts_with_g,
        :add, :color, :greena,
      )

      _ok.should eql [ :last_delivery_result, :greena ]
      o._a.should eql [ :greena ]
    end

    def _new
      __subject_class.new
    end

    shared_subject :__subject_class do

      class ACS_28_6_18

        def initialize
          @_a = []
        end

        attr_reader(
          :_a,
        )

        def edit_entity * x_a, & x_p
          ACS_[].edit x_a, self, & x_p
        end

        def __color__component_association

          yield :can, :add

          -> st do
            Common_::Known_Known[ st.gets_one ]
          end
        end

        def component_is__color_starts_with_g__ qk, & _

          if 'g' == qk.value_x[ 0 ]
            true
          else
            false
          end
        end

        def __add__component qk, & _x_p
          x = qk.value_x
          @_a.push x
          x
        end

        def result_for_component_mutation_session_when_changed o, & __

          [ :last_delivery_result, o.last_delivery_result ]
        end

        def result_for_component_mutation_session_when_no_change & __

          :welff_nothing_happened
        end

        ACS_ = -> do
          Home_
        end

        self
      end
    end
  end
end
