require_relative '../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] for interface - (2) arg arity & related" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event
    use :expect_root_ACS

    context "invalid under the plural" do

      call_by_ do
        call_ :set, :paths, [ 'ok', '/erp' ]
      end

      it "fails" do
        root_ACS_result.should be_common_result_for_failure
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
        root_ACS_result.should eql :_yerf_
      end

      it "writes to plural ivar" do
        root_ACS._the_ivar.should eql %w( ok yerp )
      end
    end

    context "valid under singular" do

      call_by_ do
        call_ :set, :path, [ 'yay' ]
      end

      it "succeeds" do
        root_ACS_result.should eql :_yerf_
      end

      it "writes to plural ivar" do
        root_ACS._the_ivar.should eql %w( yay )
      end
    end

    shared_subject :subject_root_ACS_class do

      class MC_2_Xx

        class << self
          alias_method :new_cold_root_ACS_for_expect_root_ACS, :new
          private :new
        end  # >>

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
              Common_::Known_Known[ s ]
            end
          end
        end

        def __set__component qk, & _x_p

          instance_variable_set qk.name.as_ivar, qk.value_x
          :_yerf_
        end

        def _the_ivar
          @paths
        end

        self
      end
    end
  end
end
