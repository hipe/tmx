module Skylab::Brazen
  # ->
    class Actionesque::Factory

      Events = ::Module.new

      Events::Entity_Not_Found_for_One = Callback_::Event.prototype_with(

        :entity_not_found,
        :model, nil,
        :describable_source, nil,
        :error_category, :key_error,  # meh
        :ok, false

      ) do | y, o |

        _lemma = o.model.name_function.as_human
        _source = o.describable_source.description_under self

        y << "in #{ _source } there are no #{ plural_noun _lemma }"
      end

      Events::Entity_Not_Found = Callback_::Event.prototype_with(

        :entity_not_found,
        :identifier, nil,
        :model, nil,
        :describable_source, nil,
        :error_category, :key_error,
        :ok, false

      ) do | y, o |

        mo = o.model
        if mo

          _nf = if mo.respond_to? :name_function
            mo.name_function
          else
            Callback_::Name.via_module mo
          end

          _subj = " #{ _nf.as_human } with"
        end

        _identifier = o.identifier.description_under self

        ds = o.describable_source
        if ds
          _prep_phrase = " in #{ ds.description_under self }"
        end

        _source = o.describable_source.description_under self

        y << "there is no#{ _subj } #{ _identifier }#{ _prep_phrase }"
      end
    end
    # <-
end
