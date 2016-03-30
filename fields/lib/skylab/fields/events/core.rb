module Skylab::Fields

  module Events

    Autoloader_[ self ]
  end

  Home_.const_get :Event_, false
  module Event_  # #[#sl-155] scope stack trick

    Events::Missing = Callback_::Event.prototype_with(  # see [#036]

      :missing_required_attributes,

      :reasons, nil,  # #"c1"
      :selection_stack, nil,
      :lemma, DEFAULT_PROPERTY_LEMMA_,
      :error_category, :argument_error,
      :ok, false,

    ) do |y, o|

      o._begin_expression_session_for( y, self )._express
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

      # this event expresses as a stream of statement-ishes.. #"c2"

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

      # algorithm overview at #"c6". at present this recursion is self-
      # contained: the subject node "knows" that it is recursing with other
      # instances of its own class. but imagine that one day it might not
      # because we would like to open it up when a need arises :#here.

      def _express

        @_atoms = nil
        @_recurses = nil

        st = Callback_::Stream.via_nonsparse_array remove_instance_variable :@reasons

        reason_x = st.gets

        @_add_as_atom = method :__first_add_as_atom
        @_add_as_recurse = method :__first_add_as_recurse

        @_subject_string = Determine_any_subject_string[ self ]

        begin
          if reason_x.respond_to? :name_symbol
            @_add_as_atom[ reason_x ]
          else
            @_add_as_recurse[ reason_x ]
          end
          reason_x = st.gets
        end while reason_x


        if @_atoms
          __express_atoms
        end

        if @_recurses
          __express_recurses
        end

        @_downstream_yielder
      end

      def __first_add_as_atom nf

        @_atoms = Home_.lib_.human::NLP::EN::Sexp::Expression_Sessions::List_through_Treeish_Aggregation.begin
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

        @_recurses = Home_.lib_.human::NLP::EN::Sexp::Expression_Sessions::List_through_Treeish_Aggregation.begin

        @_add_as_recurse = method :__main_add_as_recurse
        @_add_as_recurse[ x ]
      end

      def __main_add_as_atom nf

        _reason = Missing_Required_Attribute_Synopsis_Predicate.new_by_ do |o|
          o.attribute_lemma_symbol = @lemma
          o.formal_attribute = nf
        end

        _ = _reason.to_predicateish_sexp_
        @_atoms.add_sexp _
        NIL_
      end

      def __main_add_as_recurse reason_x

        @_ff_pfx ||= Callback_::Known_Known[ __determine_any_prefix ]

        atr = reason_x.compound_formal_attribute

        k = atr.name_symbol

        if @_recurse_memory[ k ]
          adv = :also
        else
          @_recurse_memory[ k ] = true
          @_recurse_queue.push reason_x
        end

        _styled_surface_verb = @expression_agent_.calculate do
          nm atr.name
        end

        _hard_coded_for_now = [ :statementish,
          :freeform_prefix, @_ff_pfx.value_x,
          :verb_phrase, [
            :predicateish,
            :auxiliary, :must,
            :early_adverbial_phrase, adv,
            :surface_verb, _styled_surface_verb,
          ],
        ]  # near #here

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
        st = Callback_::Stream.via_nonsparse_array _
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
          self._DESIGN_ME  # #open [#ze-030]:#A
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
