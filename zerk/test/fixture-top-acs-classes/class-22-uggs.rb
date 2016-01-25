module Skylab::Zerk::TestSupport

  class Fixture_Top_ACS_Classes::Class_22_Uggs

    # NOTE read the note in the first spec that uses this node.

    def initialize
      @_is = false
    end

    # -- just for availability

    def __flickerer__component_operation

      yield :is_available, @_is

      -> do
        :_yep_
      end
    end

    def make_flickerer_available_!
      @_is = true
    end

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
  end
end
# #tombstone: `primitivesque_component_operation_for`
