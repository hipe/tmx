module Skylab::MyTerm

  class Models_::Adapter

    # a controller that
    #   1) lists available adapters
    #   2) processes a change to the selected adapter
    #   3) maintains a readable reference to any selected adapter
    #   4) the selected adapter name is persisted *as a reference*

    # -- Construction methods

    class << self

      def interpret_component st, asc, acs, & p
        if st.unparsed_exists
          Unresolved_Reference___.new st.gets_one, asc.name, acs, & p
        else
          new nil, asc.name, acs, & p
        end
      end

      def _via_selected_adapter ada, nf, svs, & p
        new ada, nf, svs, & p
      end

      private :new
    end  # >>

    # -- Unserialization intermediary

    class Unresolved_Reference___

      # see [#003]:#note-about-serialized-references

      def initialize s, nf, svs, & oes_p_p

        @_nf = nf
        @_oes_p_p = oes_p_p
        @s = s
        @svs = svs
      end

      def unserialize_

        _oes_p = @_oes_p_p[ NIL_ ]

        ada = Adapter_via_string__[ @s, @svs, & _oes_p  ]
        if ada

          # breaking immutability, it is this codepoint that decides what
          # adapter is selected. it does not notify the adapter's custodian.

          ada.mutate_by_becoming_selected_

          Here_._via_selected_adapter ada, @_nf, @svs, & @_oes_p_p
        else
          ada
        end
      end
    end

    # -- Initializers

    def initialize ada, nf, svs, & oes_p_p

      @_nf = nf
      @_oes_p_p = oes_p_p
      @_svs = svs

      @_oes_p = oes_p_p[ self ]

      if ada
        @_has_selected_adapter = true
        @_selected_adapter = ada
      else
        @_has_selected_adapter = false
      end
    end

    # -- Expressive event hook-outs

    def describe_into_under y, expag  # for modality clients
      ACS_[]::Infer::Description[ y, expag, @_nf, self ]
    end

    def description_under expag  # for [#br-035] expressive events

      ada = @_selected_adapter
      expag.calculate do
        nm ada.adapter_name
      end
    end

    # -- ACS hook-ins

    def to_primitive_for_component_serialization  # for s11n
      @_selected_adapter.adapter_name.as_slug
    end

    # -- Operations

    def __set__component_operation

      yield :description, -> y do
        y << "set the adapter"
      end

      yield :parameter, :adapter, :description, -> y do
        y << "the name of the adapter to use"
        y << "(see `list` for a list of adapters)"   # etc
      end

      method :___receive_set_adapter_name
    end

    def ___receive_set_adapter_name adapter

      _add_verb = -> * i_a, & ev_p do

        # probably a failure to resolve 1 adapter name. add the verb `set`

        o = Linked_list_[]
        _end = o[ nil, ev_p ]
        _LL = o[ _end, :set ]

        @_oes_p.call i_a.fetch( 0 ), :contextualized, * i_a[ 1..-1 ] do
          _LL
        end
      end

      ada = Adapter_via_string__[ adapter, @_svs, & _add_verb ]
      if ada
        ___change_via ada
      else
        ada
      end
    end

    def ___change_via ada

      # epic: when a new valid adapter is selected, feign immutability and
      # make a new version of yourself that reflects the change. send this
      # new version in a signal to any custodian, which should swap in new
      # for old and generate a natural-sounding event. s11n works.
      # (we do not currently check if new adapter is same as old for one reason)

      if @_has_selected_adapter
        @_selected_adapter.mutate_by_becoming_not_selected__
      end

      ada.mutate_by_becoming_selected_

      new_self = self.class._via_selected_adapter ada, @_nf, @_svs, & @_oes_p_p

      @_oes_p.call :change do
        new_self
      end
    end

    def __list__component_operation

      yield :description, -> y do
        y << "list the available adapters"
      end

      -> do
        @_svs.adapters_.all_to_stream__
      end
    end

    # -- Project hook-outs

    def selected_adapter__
      @_selected_adapter or self._SANITY
    end

    load_ticket_via_string = nil

    Adapter_via_string__ = -> s, svs, & oes_p do

      # for unserialization and UI.
      # allow partial match, be expressive about failure.

        lt = load_ticket_via_string[ s, svs, & oes_p ]
        if lt
          svs.adapters_.adapter_for_load_ticket_ lt
        else
          lt
        end
      end

      load_ticket_via_string = -> s, svs, & oes_p do

        cache = svs.kernel_.silo( :Adapters ).cache

        o = Brazen_::Collection::Common_fuzzy_retrieve.new( & oes_p )

        o.set_qualified_knownness_value_and_symbol s, :adapter

        o.stream_builder = -> do
          cache.to_value_stream
        end

        o.name_map = -> lt do
          lt.adapter_name.as_distilled_stem
        end

        o.success_map = -> lt do
          lt  # hi
        end

        o.execute
      end
    # -

    Here_ = self
  end
end
