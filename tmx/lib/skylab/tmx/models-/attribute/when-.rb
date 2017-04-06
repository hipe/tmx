module Skylab::TMX

  class Models_::Attribute

    When_ = ::Module.new

    module WhenScratchSpace____

      # ==

      # ==

      When_::Unparsable_attributes_in_JSON_file = -> hum_a, file, h, listener do

        listener.call :error, :expression, :parse_error do |y|

          h ||= MONADIC_EMPTINESS_

          msgs = []
          no_reasons = nil
          hum_a.each do |hum|

            reason_sym, _formal_d = h[ hum ]

            if reason_sym
              UNPARSABLE_REASONS____.fetch( reason_sym )[ msgs, hum ]
            else
              ( no_reasons ||= [] ).push hum
            end
          end

          if no_reasons
            msgs << "unrecognized attribute(s) #{ no_reasons.inspect }"  # trivial to naturalize
          end

          if 1 == msgs.length
            msg = msgs.fetch 0
            if msg.include? ' - ' # eew, meh
              y << "#{ msg } (in #{ file })"
            else
              y << "#{ msgs } in #{ file }"
            end
          else
            y << "in #{ file }:"
            msgs.each do |msg_|
              y << "  - #{ msg_ }"
            end
          end
        end
        UNABLE_
      end

      # ==

      o = {}
      UNPARSABLE_REASONS____ = o
      o[ :_because_is_derived_ ] = -> y, hum do
        y << "#{ hum.inspect } is a derived attribute - cannot be assigned directly"
      end
      o = nil

      # ==

      When_::Unrecognized_attribute_levenshtein = -> k, attrs, listener do

        listener.call :error, :expression, :parse_error, :unknown_attribute do |y|

          _scn = Stream_.call attrs do |attr|
            attr.name
          end.flush_to_scanner

          _stringify_by = -> name do
            name.as_lowercase_with_underscores_string
          end

          _ickify_by = -> name do
            ick_prim name.as_lowercase_with_underscores_symbol
          end

          _s_a = Home_.lib_.human::Levenshtein.via(
            :item_string, k.id2name,
            :items, _scn,
            :stringify_by, _stringify_by,
            :map_result_items_by, _ickify_by,
            :closest_N_items, 3,
          )

          _first_sentence = "unrecognized attribute \"#{ ick_prim k }\"."
          _second_sentence = "did you mean #{ Common_::Oxford_or[ _s_a ] }?"

          y << "#{ _first_sentence } #{ _second_sentence }"
        end

        UNABLE_
      end

      # ==

      When_::Has_no_implementation = -> m, primary_sym, me, listener do

        listener.call :error, :expression, :parse_error, :no_implementation_for, primary_sym do |y|

          _subj = ick_prim me.name.as_lowercase_with_underscores_symbol
          _topic = prim primary_sym
          y << "#{ _subj } has no implementation for #{ _topic }."
          y << "(maybe defined `#{ m }` for #{ me.implementation.class }?)"
        end
        UNABLE_
      end

      # ==

      # ==
    end
  end
end
