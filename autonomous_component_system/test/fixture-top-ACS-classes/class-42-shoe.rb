module Skylab::Autonomous_Component_System::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_42_Shoe

      # -

        class << self
          alias_method :new_cold_root_ACS_for_expect_root_ACS, :new
          private :new
        end  # >>

        def edit * x_a, & x_p

          _oes_p_p = -> _ do
            x_p
          end

          Home_.edit x_a, self, & _oes_p_p
        end

        def __lace__component_association
          Lace
        end

        def __set_size__component_operation

          -> size, special do

            @size = size
            @special = special

            true  # ACHIEVED_
          end
        end

        def __set_color_of_upper__component_operation

          yield :parameter, :blink, :default, :no_blink

          yield :parameter, :alpha, :default_proc, -> { ___yes_alpha }

          -> red, green, blue, alpha, blink do
            [ red, green, blue, alpha, blink ]  # abuse - must be truish
          end
        end

        def ___yes_alpha
          :yes_alpha
        end

        def result_for_component_mutation_session_when_changed o

          x = o.last_delivery_result
          if true == x
            :_yergen_
          else
            x
          end
        end

        attr_reader( :lace, :size, :special )

        # -

      class Lace

        Be_compound[ self ]

        def __color__component_association
          Color
        end

        attr_reader :color
      end

      class Color

        Be_component[ self ]

        def initialize _st
          # ..
        end

        def description_under exp
          s = @string
          exp.calculate { val s }
        end

        def __set__component_operation

          -> x, & oes_p_p do

            if oes_p_p
              use_p = oes_p_p[ nil ]
            else
              self._COVER_ME  # use @oes_p_
            end

            use_p.call :info, :expression, :hi do | y |
              y <<  "hi #{ highlight 'there' }"
            end

            @string = x
            true
          end
        end

        attr_reader :string
      end
    end
  end
end
