module Skylab::Autonomous_Component_System::TestSupport

  module Operation::Support

    class << self

      def [] tcc
        tcc.include self
      end
    end  # >>

    TS_::TestLib_::Memoizer_methods[ self ]

    memoize :shoe_model_ do

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

      Local_Lib__ = TS_.lib :support

      class Lace

        Local_Lib__::Common_child_class_methods[ self ]

        def initialize & x_p
          # (hi.)
          @oes_p_ = x_p
        end

        def __color__component_association
          Color
        end

        attr_reader :color
      end

      class Color

        Local_Lib__::Common_child_methods[ self ]

        def __set__component_operation

          -> x, & call_p do

            if call_p
              use_p = call_p
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

      Shoe
    end

    ACS__  = -> do
      Home_
    end
  end
end
