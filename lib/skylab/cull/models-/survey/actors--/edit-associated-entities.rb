module Skylab::Cull

  class Models_::Survey

    class Actors__::Edit_associated_entities

      Callback_::Actor.call self, :properties,
        :passed_arg_a,
        :arg_box,
        :survey

      def execute
        ok = ACHIEVED_

        st = Callback_.stream.via_nonsparse_array @passed_arg_a

        while arg = st.gets

          md = RX___.match arg.name_symbol

          ok = if md

            via_associated_entity( arg,
              md[ :add ] ? :add : :remove,
              md[ :stem ].intern )

          elsif Models__.const_defined?( arg.name.as_const, false )

            via_associated_entity( arg,
              :set,
              arg.name.as_lowercase_with_underscores_symbol )

          else
            KEEP_PARSING_
          end
          ok or break
        end
        ok
      end

      RX___ = /\A(?:(?<add>add_)|(?<remove>remove_))(?<stem>.+)/

      def via_associated_entity arg, verb_sym, ent_sym
        @survey.touch_associated_entity_( ent_sym ).send(
          verb_sym, arg, @arg_box )
      end
    end
  end
end
