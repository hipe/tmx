module Skylab::Brazen

  module Entity

    module Small_Time_Actors__

      class Prop_desc_wonderhack

        Callback_::Actor[ self, :properties, :expag, :prop ]

        def execute

          # hack a description of a [meta] property that presumably has no
          # name yet based solely on this terrible hack of what we infer
          # are the [meta] meta properties of interest (derived from
          # set arithmetic on ivars and classes SO FRAGILE SO FUN)

          _i_a = @prop.class.polymorphic_writer_method_name_dictionary.keys

          _i_a_ = @prop.instance_variables.map do | ivar |
            ivar.id2name[ 1 .. -1 ].intern
          end

          existent = _i_a & _i_a_

          rx = /=$/

          _intrinsic = Callback_::Actor::Methodic__::Simple_Property__.
            private_instance_methods( false ).reduce [] do | m, m_i |
              md = rx.match m_i
              if md
                m.push md.pre_match.intern
              end
              m
            end

          any = existent - _intrinsic

          use = if any.length.nonzero?
            any
          elsif existent.length.nonzero?
            existent
          end

          if use
            prop = @prop
            @expag.calculate do
              _ast_a = use.map do | sym |
                _x = prop.instance_variable_get :"@#{ sym }"
                "#{ sym } = #{ ick _x }"
              end
              "(#{ _ast_a * ', ' })"
            end
          else
            "[ no name yet ]"
          end
        end
      end
    end
  end
end
