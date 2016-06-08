module Skylab::Fields

  module Event_

    DEFAULT_PROPERTY_LEMMA_ = :attribute

    # NOTE  this node holds facilities that were abstracted from a *single*
    # event class. don't assume that you must use this node for your event.

    Sexper__ = ::Class.new

    class Missing_Required_Attribute_Synopsis_Predicate < Sexper__

      # "is missing required attribute «foo»"

      # formerly "reason", we anticipated exposing this node which is why
      # it is here and not in the support node for now..

      Prototype = Lazy_.call do
        o = _begin_toplevel_prototype
        o.attribute_lemma_symbol = DEFAULT_PROPERTY_LEMMA_
        o.modifier_word_list = %w( required )
        o.freeze
      end

      def _init_by_one x
        self.formal_attribute = x
      end

      attr_writer(
        :attribute_lemma_symbol,
        :formal_attribute,
        :modifier_word_list,
      )

      def to_predicateish_sexp_

        _guy = [ :for_expag, :par, @formal_attribute ]

        [ :predicateish,  # as demonstrated in test [#hu-053]
          :lemma, :be,
          :object_noun_phrase, [
            :gerund_phraseish,
            :verb_lemma, :miss,  # for "missing"
            :object_noun_phrase, [
              :nounish,
              :lemma, @attribute_lemma_symbol,
              :modifier_word_list, @modifier_word_list,
              :proper_noun, _guy,
            ],
          ],
        ]
      end

      attr_reader(
        :attribute_lemma_symbol,
      )
    end

    class Sexper__

      class << self

        def new_by_
          o = self::Prototype[].dup
          yield o
          o.freeze
        end

        alias_method :_begin_toplevel_prototype, :new
        undef_method :new
      end  # >>

      def initialize
        # (hi.) (1x)
      end
    end

    # ==

    class Determine_any_subject_string < Common_::Actor::Monadic

      # ..

      def initialize o
        @_expag = o.expression_agent_
        @selection_stack = o.selection_stack
      end

      def execute
        ss = @selection_stack
        if ! ss
          ss = EMPTY_A_
        end
        case 1 <=> ss.length
        when -1 ;
          __subject_X_when_selection_stack_of_length_greater_than_one ss
        when 1
          __subject_X_when_selection_stack_is_zero_length
        else
          __subject_X_when_selection_stack_is_of_length_one ss.first
        end
      end

      def __subject_X_when_selection_stack_is_zero_length
        NOTHING_
      end

      def __subject_X_when_selection_stack_is_of_length_one x
        self._WRITE_ME_selection_stack_has_length_of_one
      end

      def __subject_X_when_selection_stack_of_length_greater_than_one ss

        st = Common_::Stream.via_times ss.length

        o = Home_.lib_.basic::Yielder::Mapper.joiner "", SPACE_
        y = o.y

        st.gets  # skip first frame, has no name..

        @_expag.calculate do
          begin
            d = st.gets
            d or break
            _x_o = ss.fetch d
            y << nm( _x_o.name )
            redo
          end while nil
        end

        o.downstream_yielder
      end
    end

    # ==

  end
end
# #history: abstracted from the "missing" event
