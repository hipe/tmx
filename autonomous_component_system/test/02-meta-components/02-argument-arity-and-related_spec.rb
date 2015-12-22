require_relative '../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] for interface - (2) arg arity & related" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event

    context "invalid under the plural" do

      call_by_ do
        call_ :set, :paths, [ 'ok', '/erp' ]
      end

      it "fails" do
        result_.should be_result_for_failure_
      end

      it "the plural validates with the singular" do
        only_emission.should be_emission( :error, :expression, :cant_have_it )
      end
    end

    context "valid under plural" do

      call_by_ do
        call_ :set, :paths, [ 'ok', 'yerp' ]
      end

      it "succeeds" do
        result_.should eql :_yerf_
      end

      it "writes to plural ivar" do
        state_.root._the_ivar.should eql %w( ok yerp )
      end
    end

    context "valid under singular" do

      call_by_ do
        call_ :set, :path, [ 'yay' ]
      end

      it "succeeds" do
        result_.should eql :_yerf_
      end

      it "writes to plural ivar" do
        state_.root._the_ivar.should eql %w( yay )
      end
    end

    shared_subject :my_model_ do

      class MC_2_Xx

        def __paths__component_association

          yield :can, :set

          yield :is_plural_of, :path
        end

        def __path__component_association

          yield :can, :set

          yield :is_singular_of, :paths

          -> st, & oes_p_p do

            s = st.gets_one
            if ::File::SEPARATOR == s[ 0 ]
              oes_p_p[ nil ].call :error, :expression, :cant_have_it
              UNABLE_
            else
              Callback_::Known_Known[ s ]
            end
          end
        end

        def __set__component x, asc, & _ignored

          instance_variable_set asc.name.as_ivar, x
          :_yerf_
        end

        def result_for_component_mutation_session_when_changed o
          o.last_delivery_result
        end

        def _the_ivar
          @paths
        end

        self
      end
    end
  end
end
