module Skylab::Brazen::TestSupport

  module Autonomous_Component_System::Operation::Support

    class << self

      def [] tcc
        tcc.include self
      end

      def _memoize sym, & p
        define_method sym, & Callback_::Memoize[ & p ]
      end
    end  # >>

    _memoize :shoe_model_ do

      class Shoe

        class << self
          alias_method :new_, :new
          private :new
        end  # >>

        def edit * x_a, & x_p
          ACS__[].edit x_a, self, & x_p
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

          # (not the below are in an intentionally weird order to
          #  assert that the order doesn't see expression (yet))

          -> green, red, blink=:no_blink, alpha=:yes_alpha, blue do

            [ red, green, blue, alpha, blink ]  # abuse - must be truish
          end
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
      end

      Local_Lib__ = TS_.lib :autonomous_component_system_support

      class Lace

        Local_Lib__::Common_child_methods[ self ]

        def __color__component_association
          Color
        end

        attr_reader :color
      end

      class Color

        Local_Lib__::Common_child_methods[ self ]

        def __set__component_operation

          -> x do

            @oes_p_.call :info, :expression, :hi do | y |
              y <<  "hi #{ highlight 'there' }"
            end

            @string = x
            true
          end
        end

        attr_reader :string
      end

      Shoe
    end

    ACS__  = -> do
      Home_::Autonomous_Component_System
    end
  end
end
