module Skylab::Fields

  module Events
    Autoloader_[ self ]
  end

  Home_.const_get :Event_, false
  module Event_  # #[#sl-155] scope stack trick

    Events::Missing = Common_::Event.prototype_with(  # see [#036]

      :missing_required_attributes,

      :reasons, nil,  # #[#here.A]
      :selection_stack, nil,
      :noun_lemma, DEFAULT_PROPERTY_LEMMA_,
      :USE_THIS_EXPRESSION_AGENT_METHOD_TO_DESCRIBE_THE_PARAMETER, :par,
      :exception_class_by, -> { Home_::MissingRequiredAttributes },  # ..
      :error_category, :argument_error,
      :ok, false,

    ) do |y, o|

      o._begin_expression_session_for( y, self )._express
    end

    class Events::Missing

      # this event expresses as a stream of statement-ishes.. #[#here.B]

      def _begin_expression_session_for y, expag
        dup.___init_dup_for_expression y, expag
      end

      def ___init_dup_for_expression y, expag  # assume ad-hoc mutable
        @expression_agent_ = expag
        @_downstream_yielder = y
        @_recurse_memory = nil
        self
      end

      attr_writer(
        :_recurse_memory,
      )

      # algorithm overview at [#here.F]. at present this recursion is self-
      # contained: the subject node "knows" that it is recursing with other
      # instances of its own class. but imagine that one day it might not
      # because we would like to open it up when a need arises :#here-1

      def _express

        @_atoms = nil
        @_recurses = nil

        @_add_as_atom = method :__first_add_as_atom
        @_add_as_recurse = method :__first_add_as_recurse

        x = remove_instance_variable :@reasons
        st = if x.respond_to? :gets
          x
        else
          Stream_[ x ]
        end

        @_subject_string = Determine_any_subject_string[ self ]

        begin
          reason_x = st.gets
          reason_x || break
          if reason_x.respond_to? :intern or reason_x.respond_to? :name_symbol
            @_add_as_atom[ reason_x ]
          else
            @_add_as_recurse[ reason_x ]
          end
          redo
        end while above

        if @_atoms
          __express_atoms
        end

        if @_recurses
          __express_recurses
        end

        @_downstream_yielder
      end

      def __first_add_as_atom nf

        @_atoms = Home_.lib_.human::NLP::EN::Magnetics::List_via_TreeishAggregation_of_Phrases.begin
        @_add_as_atom = method :__main_add_as_atom
        @_add_as_atom[ nf ]
      end

      def __first_add_as_recurse x

        if @_recurse_memory
          NOTHING_  # (hi.) - this mean you are not the originator of expression
        else
          @_recurse_memory = {}
        end
        @_recurse_queue = []

        @_recurses = Home_.lib_.human::NLP::EN::Magnetics::List_via_TreeishAggregation_of_Phrases.begin

        @_add_as_recurse = method :__main_add_as_recurse
        @_add_as_recurse[ x ]
      end

      def __main_add_as_atom nf

        _reason = Missing_Required_Attribute_Synopsis_Predicate.new_by_ do |o|
          o.association = nf
          o.attribute_lemma_symbol = @noun_lemma
          o.THIS_ONE_METHOD = @USE_THIS_EXPRESSION_AGENT_METHOD_TO_DESCRIBE_THE_PARAMETER
        end

        _ = _reason.to_predicateish_sexp_
        @_atoms.add_sexp _
        NIL_
      end

      def __main_add_as_recurse reason_x

        @_ff_pfx ||= Common_::KnownKnown[ __determine_any_prefix ]

        asc = reason_x.compound_formal_attribute

        k = asc.name_symbol

        if @_recurse_memory[ k ]
          adv = :also
        else
          @_recurse_memory[ k ] = true
          @_recurse_queue.push reason_x
        end

        _styled_surface_verb = @expression_agent_.calculate do
          nm asc.name
        end

        _hard_coded_for_now = [ :statementish,
          :freeform_prefix, @_ff_pfx.value,
          :verb_phrase, [
            :predicateish,
            :auxiliary, :must,
            :early_adverbial_phrase, adv,
            :surface_verb, _styled_surface_verb,
          ],
        ]  # near #here-1

        @_recurses.add_sexp _hard_coded_for_now

        NIL_
      end

      def __determine_any_prefix
        ss = @_subject_string
        if ss
          "to #{ ss }"
        end
      end

      def __express_recurses

        _  = remove_instance_variable :@_recurses

        _ = _.expression_via_finish

        _.express_into_under @_downstream_yielder, @expression_agent_

        _ = remove_instance_variable :@_recurse_queue
        st = Stream_[ _ ]
        begin
          x = st.gets
          x or break
          ___recurse x
          redo
        end while nil

        @_downstream_yielder
      end

      def ___recurse reason_x

        # (a custom #[#ca-046] emission handling pattern.)

        em_a = reason_x.emissions
        if 1 < em_a.length
          self._DESIGN_ME  # #open [#ze-030.1]
        end

        em = em_a.fetch 0

        if :expression == em.channel.fetch( 1 )

          @expression_agent_.calculate @_downstream_yielder, & em.mixed_event_proc
          NIL_
        else
          ___express_event em
          NIL_
        end
      end

      def ___express_event em

        _ev = em.mixed_event_proc.call

        o = _ev._begin_expression_session_for(
          @_downstream_yielder, @expression_agent_ )

        o._recurse_memory = @_recurse_memory

        o._express
        NIL_
      end

      def __express_atoms

        ss = @_subject_string

        exp = @_atoms.expression_via_finish

        _st = if ss
          exp.to_statementish_stream_for_subject :nounish, :proper_noun, ss
        else
          exp.to_statementish_stream_for_no_subject
        end

        _express_this_statementish_stream _st
      end

      def _express_this_statementish_stream st

        begin
          exp = st.gets
          exp or break
          exp.express_into_under @_downstream_yielder, @expression_agent_
          redo
        end while nil
        @_downstream_yielder
      end

      attr_reader(
        :expression_agent_,
        :_recurse_memory,
      )
    end
  end
end
