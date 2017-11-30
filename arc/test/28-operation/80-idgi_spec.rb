require_relative '../test-support'

module Skylab::Arc::TestSupport

  describe "[arc] operation - idgi - for interface - arg arity & related" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event
    use :want_root_ACS

    context "invalid under the plural" do

      call_by_ do
        call_ :set, :paths, [ 'ok', '/erp' ]
      end

      it "fails" do
        expect( root_ACS_result ).to be_common_result_for_failure
      end

      it "the plural validates with the singular" do
        expect( only_emission ).to be_emission( :error, :expression, :cant_have_it )
      end
    end

    context "valid under plural" do

      call_by_ do
        call_ :set, :paths, [ 'ok', 'yerp' ]
      end

      it "succeeds" do
        expect( root_ACS_result ).to eql :_yerf_
      end

      it "writes to plural ivar" do
        expect( root_ACS._the_ivar ).to eql %w( ok yerp )
      end
    end

    context "valid under singular" do

      call_by_ do
        call_ :set, :path, [ 'yay' ]
      end

      it "succeeds" do
        expect( root_ACS_result ).to eql :_yerf_
      end

      it "writes to plural ivar" do
        expect( root_ACS._the_ivar ).to eql %w( yay )
      end
    end

    shared_subject :subject_root_ACS_class do

      class MC_2_Xx

        class << self
          alias_method :new_cold_root_ACS_for_want_root_ACS, :new
          private :new
        end  # >>

        def __paths__component_association

          yield :can, :set

          yield :is_plural_of, :path
        end

        def __path__component_association

          yield :can, :set

          yield :is_singular_of, :paths

          -> st, & p_p do

            s = st.gets_one
            if ::File::SEPARATOR == s[ 0 ]
              p_p[ nil ].call :error, :expression, :cant_have_it
              UNABLE_
            else
              Common_::KnownKnown[ s ]
            end
          end
        end

        def __set__component qk, & _x_p

          instance_variable_set qk.name.as_ivar, qk.value
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
