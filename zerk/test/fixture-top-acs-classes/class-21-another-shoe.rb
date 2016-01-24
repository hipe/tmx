module Skylab::Zerk::TestSupport

  class Fixture_Top_ACS_Classes::Class_21_Another_Shoe

    # (similar to another model elsewhere)

    # -- Components

    def __lace__component_association

      Lace
    end

    # -- Modality hook-outs

    # -- Operations

    def __globbie_guy__component_operation

      -> * file do
        file
      end
    end

    def __globbie_complex__component_operation

      -> action, is_dry=false, verbose=false, *file do

        [ action, is_dry, verbose, file ]
      end
    end
  end

  class Lace

    Be_component[ self ]

    def initialize & oes_p_p

      @color = 'white'
      @_oes_p = oes_p_p[ self ]
    end

    def __get_color__component_operation

      -> & use_p do  # [#006]#Event-models

        use_p.call :info, :expression, :working do | y |
          y << "retrieving #{ highlight 'color' }"
        end

        @color
      end
    end

    def __set_length__component_operation

      -> length, & call_p do

        use_p = call_p  # currently, parents have no signal processing methods

        x = length

        ok = if x.respond_to? :bit_length
          true
        else

          if /\A-?\d+\z/ =~ x
            x = x.to_i
            true
          else
            use_p.call :info, :expression, :not_int do | y | y << 'not.' end
            false
          end
        end

        if ok

          if 0 >= x
            use_p.call :info, :expression, :too_low do | y | y << 'low.' end
            false
          else
            @x = x
            :_yay_
          end
        else
          ok
        end
      end
    end
  end
end
