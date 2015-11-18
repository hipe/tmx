require_relative '../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] ACS tenet 7 A - the `via` modifier" do

    extend TS_
    use :memoizer_methods

    it "on a construction" do

      _hi = _subject_class.edit_entity(
        :via, :regulo_expo, :set, :thingo, /Zaa/ )

      _hi.thingo.sym.should eql :is_regex
    end

    it "on an edit" do

      hi = _subject_class.send :new  # eek

      ok = hi.edit_entity :via, :procky, :set, :thingo, -> x {-x}

      ok.should eql true

      hi.thingo.sym.should eql :is_prockie
    end

    dangerous_memoize_ :_subject_class do

      class ACS_7_Via_1

        class << self

          def edit_entity * x_a, & x_p
            ACS_[].create x_a, new, & x_p
          end

          private :new
        end

        def edit_entity * x_a, & x_p
          ACS_[].edit x_a, self, & x_p
        end

        def result_for_component_mutation_session_when_changed _, & __
          true
        end

        def __set__component x, ca, & oes_p

          instance_variable_set ca.name.as_ivar, x
          true
        end

        attr_reader :thingo

        def __thingo__component_association
          yield :can, :set
          ACS_7_Thinger
        end

        class ACS_7_Thinger

          class << self
            def new_via__regulo_expo__ rx
              new :is_regex
            end
            def new_via__procky__ x
              new :is_prockie
            end
            private :new
          end  # >>

          def initialize sym
            @sym = sym
          end

          attr_reader :sym
        end

        ACS_ = -> do
          Home_::Autonomous_Component_System
        end
      end

      ACS_7_Via_1
    end
  end
end
