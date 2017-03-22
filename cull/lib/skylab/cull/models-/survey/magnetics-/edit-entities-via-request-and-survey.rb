module Skylab::Cull

  class Models_::Survey

    class Actors__::Edit_associated_entities

      Attributes_actor_ = -> cls, * a do
        Home_.lib_.fields::Attributes::Actor.via cls, a
      end

      Attributes_actor_.call( self,
        :passed_arg_a,
        :arg_box,
        :survey,
      )

      def execute

        ok = ACHIEVED_
        st = Common_::Stream.via_nonsparse_array @passed_arg_a

        begin
          @_arg = st.gets
          @_arg || break

          ok = if __looks_verby
            __when_verby
          elsif __has_model
            __when_model
          else
            KEEP_PARSING_
          end

          ok ? redo : break
        end while above
        ok
      end

      def __looks_verby

        md = RX___.match @_arg.name_symbol
        if md
          @__matchdata = md
          ACHIEVED_
        end
      end

      def __when_verby

        md = remove_instance_variable :@__matchdata

        _add_or_remove = md[ :add ] ? :add : :remove
        _ok = _via_associated_entity _add_or_remove, md[ :stem ].intern
        _ok  # #todo
      end

      def __has_model

        _h = Models__.tricky_index__
        _slug = @_arg.name.as_slug
        _h[ _slug ]
      end

      def __when_model

        _sym = @_arg.name.as_lowercase_with_underscores_symbol
        _via_associated_entity :set, _sym
      end

      RX___ = /\A(?:(?<add>add_)|(?<remove>remove_))(?<stem>.+)/

      def _via_associated_entity verb_sym, ent_sym

        _ = @survey.touch_associated_entity_ ent_sym
        _.send verb_sym, @_arg, @arg_box
      end
    end
  end
end
