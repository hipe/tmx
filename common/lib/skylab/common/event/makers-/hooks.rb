module Skylab::Common

  class Event

    class Makers_::Hooks

      # [#005.D]. (this splintered from [#005.B] (more history there))

      _p = Home_.lib_.basic::Struct::Definition_for_the_Method_Called_New.via(

        :edit_class, -> edit_p=nil do

          members.each do | sym |

            attr = :"#{  sym  }_p"
            ivar = :"@#{ attr }"
            m = :"on_#{  sym  }"

            define_method m do | * a, & p |

              instance_variable_set ivar,
                ( p ? a << p : a ).fetch( a.length - 1 << 2 )
            end

            alias_method sym, m

            attr_reader attr
          end

          if edit_p
            class_exec( & edit_p )
          end
        end )

      class << self
        alias_method :orig_new, :new
      end

      define_singleton_method :new, _p

    end
  end
end
