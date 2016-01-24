require_relative '../../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] tenets - 7 D - the `assuming` modifer" do

    TS_[ self ]
    use :memoizer_methods

    it "when two assumptions pass" do

      o = _new

      o.is_fun = true
      o.is_good_times = true

      _ok = _same o

      _ok.should eql :yep
      o.jimmy_is_rattled.should eql true
      @_ev_a.should be_nil
    end

    it "when both assumptions fail - operation is short circuited" do

      o = _new
      _ok = _same o
      _ok.should eql false
      o.jimmy_is_rattled.should eql false
      @_ev_a.should eql [ :beep ]
    end

    def _new
      __subject_class.new
    end

    def _same o

      @_ev_a = nil

      o.edit_entity(
        :assuming, :fun,
        :assuming, :good_times,
        :rattle, :jimmy
      ) do | x |
        @_ev_a ||= []
        @_ev_a.push x
      end
    end

    shared_subject :__subject_class do

      class ACS_28_6_21

        def initialize
          @is_fun = @is_good_times = nil
          @_last_rattled = nil
        end

        attr_writer(
          :is_fun,
          :is_good_times,
        )

        def edit_entity * x_a, & x_p

          _oes_p_p = -> _ do
            x_p
          end

          ACS_[].edit x_a, self, & _oes_p_p
        end

        def __jimmy__component_association

          yield :can, :rattle

          -> st do
            Callback_::Known_Known[ nil ]
          end
        end

        def expect_component__fun__ _, _, & oes_p
          if @is_fun
            true
          else
            oes_p[ :beep ]
            false
          end
        end

        def expect_component__good_times__ _, _, & oes_p
          if @is_good_times
            true
          else
            oes_p[ :meep ]
            false
          end
        end

        def __rattle__component _, ca, & _x_p
          @_last_rattled = ca.name.as_variegated_symbol
          :yep
        end

        def result_for_component_mutation_session_when_changed o, &__
          o.last_delivery_result
        end

        def jimmy_is_rattled
          :jimmy == @_last_rattled
        end

        ACS_ = -> do
          Home_
        end

        self
      end
    end
  end
end
