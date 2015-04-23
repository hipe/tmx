module Skylab::Snag

  module Model_::Collection

    module Event_Factory

      Entity_Already_Added = Callback_::Event.prototype_with(

        :entity_already_added,

        :entity, nil,
        :entity_collection, nil,

        :error_category, :key_error,
        :ok, false

      ) do | y, o |

        a = []
        subject = o.entity_collection.description_under self
        subject and a.push subject

        a.push 'already'

        conjugated_verb = 'has'  # (one day [#015])
        a.push conjugated_verb

        object = o.entity.description_under self
        object and a.push object

        y << ( a * SPACE_ )
      end

      Entity_Added = Callback_::Event.prototype_with(

        :entity_added,

        :verb_i, nil,
        :tag_s, nil

      ) do | y, o|

        self._REVIEW
        y << "#{ Snag_.lib_.NLP::EN::POS::Verb[
          o.verb_i.to_s ].preterite } #{ val o.tag_s }" ; nil
      end

      def __WAS__verb_i
        @do_prepend ? :prepend : :append
      end

      # (try to add when alreayd exists:)
      # :+[#044] inline events exper. ( was )

      Entity_Not_Found = Callback_::Event.prototype_with(

        :entity_not_found,

        :xxx_o, nil

      ) do | y, o |

        self._REVIEW
        y << "#{ val o.identifier.render } is not tagged with #{
          }#{ ick o.tag_s }"
      end

      Entity_Removed = Callback_::Event.prototype_with(

        :entity_removed,

        :tag_o, nil

      ) do | y, o |

        self._REVIEW
        y << "removed #{ val o.rendered }"
      end
    end
  end
end
