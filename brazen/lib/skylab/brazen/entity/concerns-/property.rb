module Skylab::Brazen

  module Entity

    module Concerns_::Property

      class Prop_desc_wonderhack < Callback_::Actor::Dyadic

        def initialize a, b
          @expag = a
          @property = b
        end

        def execute

          # hack a description of a [meta] property that presumably has no
          # name yet based solely on this terrible hack of what we infer
          # are the [meta] meta properties of interest.

          prp = @property

          _expanse = ___property_symbols_of prp.class

          particular = prp.instance_variables.map do |ivar|
            ivar.id2name[ 1 .. -1 ].intern
          end

          intersect = _expanse & particular

          use = if intersect.length.nonzero?
            intersect
          elsif particular.length.nonzero?
            particular
          end

          if use
            @expag.calculate do
              _ast_a = use.map do | sym |
                _x = prp.instance_variable_get :"@#{ sym }"
                "#{ sym } = #{ ick _x }"
              end
              "(#{ _ast_a * ', ' })"
            end
          else
            "[ no name yet ]"
          end
        end

        def ___property_symbols_of cls  # this is :[#fi-021]
          a = []
          cls.private_instance_methods.each do |sym|
            md = RX__.match sym
            md or next
            a.push md[ 0 ].intern
          end
          a
        end

        RX__ = /\A.+(?==\z)/
      end
    end
  end
end
# #tombstone: used to do set math on the parent class
