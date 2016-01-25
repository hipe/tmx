module Skylab::Zerk::TestSupport

  class Fixture_Top_ACS_Classes::Class_21_Another_Shoe

    Require_ACS_for_testing_[]

    O__ = ACS_.test_support

    def __shoe__component_association
      Shoe
    end

  class Shoe

    O__::Be_compound[ self ]

    def __lace__component_association
      Lace
    end

    # -- Modality hook-outs

    # -- Operations

    def __globbie_guy__component_operation

      -> * file do
        file.map( & :upcase )
      end
    end

    def __globbie_complex__component_operation

      yield :parameter, :is_dry, :default, false

      yield :parameter, :verbose, :default, false

      -> action, is_dry, verbose, *file do

        [ :_fun_, action, is_dry, verbose, file ]
      end
    end
  end

  class Lace

    O__::Be_compound[ self ]

    def initialize
      @color = 'white'
    end

    def __get_color__component_operation

      -> & pp do  # [#006]#Event-models

        pp[ self ].call :info, :expression, :working do | y |
          y << "retrieving #{ highlight 'color' }"
        end

        @color
      end
    end

    def __set_length__component_operation

      -> length, & pp do

        use_p = pp[ self ]

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
    def hello
      :_hi_im_lace_
    end
  end

    def self.hello
      :_omg_shoes_
    end
  end
end
