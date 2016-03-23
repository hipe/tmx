module Skylab::Fields

  module Events

    Autoloader_[ self ]
  end

  module Events_Support_  # #[#sl-155] scope stack trick

    DEFAULT_PROPERTY_LEMMA_ = :attribute

    # --

    Events::Missing = Callback_::Event.prototype_with(

      # NOTE this is being bent to serve [#ze-027]:#Crazytimes (coming)

      :missing_required_attributes,

      :reasons, nil,  # or formal attributes
      :selection_stack, nil,
      :lemma, DEFAULT_PROPERTY_LEMMA_,
      :error_category, :argument_error,
      :ok, false,

    ) do |y, o|

      o.dup.__express_into_under y, self
    end

    class Events::Missing

      class << self

        def for_attribute x
          via [ x ]
        end

        def for_attributes a
          via a
        end

        def new_via_arglist a
          via( * a )
        end

        def via miss_a, * x_a   # miss_a [, lemma_x ]

          if x_a.length.nonzero?
            x_a.unshift :lemma
          end

          new_with :reasons, miss_a, * x_a
        end
      end  # >>

      def __express_into_under y, expag  # assume ad-hoc mutable

        @_expag = expag
        @_downstream_yielder = y

        exp = __to_aggregated_predicate_expression

        subj = __to_any_subject_string
        st = if subj
          exp.to_statementish_stream_for_subject :nounish, :proper_noun, subj
        else
          exp.to_statementish_stream_for_no_subject
        end

        begin
          exp = st.gets
          exp or break
          exp.express_into_under y, @_expag
          redo
        end while nil

        y
      end

      def __to_aggregated_predicate_expression

        agg = Home_.lib_.human::NLP::
          EN::Sexp::Expression_Sessions::List_through_Treeish_Aggregation.begin

        lemma_sym = @lemma
        if lemma_sym.respond_to? :ascii_only?
          lemma_sym = lemma_sym.intern
        end

        @reasons.each do |rsn|

          # (the oldschool way was that these are formal attributes (of one
          # of several originating libraries). the newschool way is that these
          # are reason objects. we still support the oldschool way because it
          # supports by far the most common use-case for building this event.)

          if rsn.respond_to? :name_symbol
            # if it looks like a formal attribute, upgrade it to a reason object.

            rsn = Reason._new_by do |o|
              o.attribute_lemma_symbol = lemma_sym
              o.formal_attribute = rsn
            end

          elsif rsn.attribute_lemma_symbol != lemma_sym  # eew/meh
            # otherwise, just make sure we are using the desired lemma

            rsn = rsn.__new_by do |o|
              o.attribute_lemma_symbol = lemma_sym
            end
          end

          _sx = rsn.__to_sexp
          agg.add_sexp _sx
        end

        agg.expression_via_finish
      end

      def __to_any_subject_string

        # (this is out of symmetry with the other but meh for now)

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

        st = Callback_::Stream.via_times ss.length

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

      class Reason

        Prototype___ = Lazy_.call do
          o = __begin_toplevel_prototype
          o.attribute_lemma_symbol = DEFAULT_PROPERTY_LEMMA_
          o.modifier_word_list = %w( required )
          o.freeze
        end

        class << self

          def _call fa
            _new_by do |o|
              o.formal_attribute = fa
            end
          end
          alias_method :[], :_call
          alias_method :call, :_call
          remove_method :_call

          def _new_by
            o = Prototype___[].dup
            yield o
            o.freeze
          end

          alias_method :__begin_toplevel_prototype, :new
          undef_method :new
        end  # >>

        def initialize
          # (hi.) (1x)
        end

        def __new_by
          o = dup
          yield o
          o.freeze
        end

        attr_writer(
          :attribute_lemma_symbol,
          :formal_attribute,
          :modifier_word_list,
        )

        def __to_sexp  # "is missing required property «foo»"

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
    end
  end
end
