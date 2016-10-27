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

          _st = Stream_.call attrs do |attr|
            attr.name
          end

          _stringify_by = -> name do
            name.as_lowercase_with_underscores_string
          end

          say_attr = method :say_formal_component_

          _s_a = Home_.lib_.human::Levenshtein.with(
            :item_string, k.id2name,
            :items, _st,
            :stringify_by, _stringify_by,
            :map_result_items_by, say_attr,
            :closest_N_items, 3,
          )

          _eew = Common_::Name.via_variegated_symbol k

          _first_sentence = "unrecognized attribute \"#{ say_attr[ _eew ] }\"."
          _second_sentence = "did you mean #{ Common_::Oxford_or[ _s_a ] }?"

          y << "#{ _first_sentence } #{ _second_sentence }"
        end

        UNABLE_
      end

      # ==

      When_::Has_no_implementation = -> m, primary_sym, me, listener do

        listener.call :error, :expression, :parse_error, :no_implementation_for, primary_sym do |y|

          _eew = Common_::Name.via_variegated_symbol primary_sym
          _subj = say_formal_component_ me.name
          _topic = say_primary_ _eew
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
