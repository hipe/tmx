module Skylab::Zerk::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_22_Uggs

      class << self
        alias_method :new_cold_root_ACS_for_expect_root_ACS, :new
        private :new
      end  # >>

      # <-

    def initialize
      @_flicker_yes = false
      @_ucolor_yes = true
    end

    # -- just for availability

    def __flickerer__component_operation

      yield :unavailability, -> * do
        if ! @_flicker_yes
          EMPTY_P_
        end
      end

      -> do
        :_yep_
      end
    end

    def make_flickerer_available_!
      @_flicker_yes = true
    end

    def __upper_color__component_association

      yield :unavailability, -> * do
        if ! @_ucolor_yes
          EMPTY_P_
        end
      end

      Here_::Class_72_Color
    end

    def make_ucolor_unavailable_!
      @_ucolor_yes = false
    end

    attr_reader :upper_color

    # --

    def __shoestring_length__component_association

      -> st, & pp do

        x = st.gets_one

        via_integer = -> d do
          # (more validation here .. etc)
          Callback_::Known_Known[ d ]
        end

        if x.respond_to? :bit_length
          via_integer[ x ]
        else
          md = /\A-?[0-9]+\z/.match x
          if md
            via_integer[ md[ 0 ].to_i ]
          else
            pp[ self ].call :error, :expression, :nope do | y |
              y << "doesn't look like integer: #{ x.inspect }"
            end
            false
          end
        end
      end
    end

    def set_shoestring_length_ x
      @shoestring_length = x
    end

    def get_shoestring_length_
      @shoestring_length
    end
  # ->
    end
  end
end
# #tombstone: `primitivesque_component_operation_for`
