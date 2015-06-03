module Skylab::Brazen

  module Entity

    module Concerns_::Property

      Small_Time_Actors = ::Module.new
      class Small_Time_Actors::Prop_desc_wonderhack

        Callback_::Actor.call self, :properties,

          :expag,
          :property

        def execute

          # hack a description of a [meta] property that presumably has no
          # name yet based solely on this terrible hack of what we infer
          # are the [meta] meta properties of interest (derived from
          # set arithmetic on ivars and classes SO FRAGILE SO FUN)

          prp = @property

          mine = _of prp.class

          base = _of Callback_::Actor::Methodic::Property

          uniq = mine - base

          ivars = prp.instance_variables.map do | ivar |
            ivar.id2name[ 1 .. -1 ].intern
          end

          set = ivars & uniq

          use = if set.length.nonzero?
            set
          elsif ivars.length.nonzero?
            ivars
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

        def _of cls
          a = []
          cls.private_instance_methods.each do | sym |
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
