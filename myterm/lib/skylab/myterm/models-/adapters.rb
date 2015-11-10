module Skylab::MyTerm

  class Models_::Adapters

    # whereas component associations are typically defined by special
    # methods, we express adapters as components whose associations are
    # represented by the filesystem.
    #
    # from each relevant entry in the filesystem we will derive:
    #
    #   • an "adapter name",
    #   • a "component association" for the adapter,
    #   • an adapter instance
    #
    # as needed, lazily.

    class << self

      def interpret_component st, & p

        self._HELLO  # while #open [#br-083]:#INTERP-D
      end

      def interpret_compound_component p, acs, & x_p

        # (experimental inteface)

        p[ new acs, & x_p ]
      end

      private :new
    end  # >>

    def initialize acs, & p

      @kernel_ = acs.kernel_
      @_oes_p = p
    end

    # -- exposures internal to this application --

    def touch_adapter_via_string__ s

      # assist the selected adapter controller in resolving an actual adapter
      # instance from a string. may be for use for UI and/or unserialization,
      # hence we allow partial match and are expressive about failure.

      o = Brazen_::Collection::Common_fuzzy_retrieve.new( & @_oes_p )

      o.set_qualified_knownness_value_and_symbol s, :adapter

      o.stream_builder = -> do
        _cache.to_value_stream
      end

      o.name_map = -> lt do
        lt.adapter_name.as_distilled_stem
      end

      o.success_map = -> lt do
        lt.adapter
      end

      o.execute
    end

    def to_adapter_stream_for_list__

      _cache.to_value_stream.map_by do | lt |
        lt.adapter
      end
    end

    # -- ACS-related hook-in's/hook-out's --

    def to_component_operation_symbol_stream
      NIL_  # we have no operations so don't bother indexing methods
    end

    def to_component_symbol_stream

      # when ACS reflection wants to know what all of our associations are.
      # when it is serializing a first-set adapter, it uses the same cache
      # used above. when this is unserializing, must build the cache anew.

      _cache.to_value_stream.map_by do | lt |
        lt.as_const
      end
    end

    # (assume the ACS will only ask for pieces of items we told it about.)

    def lookup_component_association const

      # from above, when ACS wants the CA from one of the symbols

      @_cache.cached( const )._component_association
    end

    def component_wrapped_value asc

      # from above, if for example serialization wants to know if there's
      # anything that needs serializing in this slot, well it's up to us:

      _lt = @_cache.cached asc.name.as_const

      ada = _lt.cached_adapter

      if ada
        Callback_::Known_Known[ ada ]
      end
    end

    def accept_component_qualified_knownness qkn  # write component value

      # ASSUMPTION CITY: we assume this is for when unserialization hands us
      # an independently finished component (adapter). (TODO: why not thru
      # UI?)
      #
      # we assume this never hands us known unknowns because those cannot be
      # expressed in serialization [#br-083]:INOUT-A.
      #
      # we assume that if the unserialization got this far, it is because we
      # confirmed that such an adapter exists in the first place, so we must
      # have already built its load ticket.
      #
      # FURTHERMORE, we assume that this is happening during unserialization
      # which happens "early" so we will not already have built and adapter
      # for that slot. whew!

      _load_ticket = @_cache.cached qkn.name.as_const

      _unserialized_adapter = qkn.value_x

      _load_ticket.cached_adapter and self._SANITY

      _load_ticket.__accept_adapter _unserialized_adapter

      NIL_
    end

    # -- receive signals from components --

    def receive__component__mutation__ asc, & p

      # (for now we do the below early for traceability)

      mutation = p.call

      mutation = mutation.flush_to_mutation_with_context__ asc

      @_oes_p.call :component, :mutation do
        x = mutation
        mutation = nil
        x
      end
    end

    # -- The Cache --

    # we maintain a cache of "load tickets". a "load ticket" is an object
    # that produces the various "pieces" of an adapter on-demand, lazily.
    #
    # this cache must work for the unserialization of any possible serialized
    # payload, so it must possibly traverse the entire adapter collection.
    # however each load ticket in the cache is itself produced lazily, so
    # for any set of adapters greater than 1 in size, there exist
    # serialization payloads the unserialization of which will not incur the
    # full traversal of the list of adapter paths. the degree to which the
    # traversal of paths will be perfectly "conservative" depends on the
    # order of entries returned by the filesystem against the constituency of
    # items in the serialized payload.
    #
    # the "pieces" of a load ticket are:
    #
    #   • the "adapter name" - an ordinary name function plus
    #     a filesystem "path" member (abstraction candidate).
    #
    #     (this feels near to [#ca-030] "boxxy" but we re-write aspects of
    #      that customly to handle any special needs present or future.)
    #
    #   • the "component adapter" - through this strcuture we reach the
    #     component model which will be used to .. LET'S SEE..
    #
    #   • the "component instance" - this will come in from the outside,
    #     and unlike normal ACS's that store these in ivars, we will store
    #     the created component instances *in* the load ticket.

    def _cache
      @_cache ||= ___build_cache
    end

    def ___build_cache

      _fs = @kernel_.silo( :Installation ).filesystem

      _ = "#{ Home_::Image_Output_Adapters_.dir_pathname.to_path }/[a-z0-9]*"

      _paths = _fs.glob _

      cr = ___build_component_reader

      _st = Callback_::Stream.via_nonsparse_array _paths do | path |
        Load_Ticket___.__new_via_path path, cr
      end

      _st.flush_to_immutable_with_random_access_keyed_to_method :as_const
    end

    def ___build_component_reader

      -> nf, cm do

        # when an adapter signals that data has changed, we want
        # those signals to reach our own handlers defined here.

        _oes_p_ = ACS_[]::Interpretation::Component_handler[ nf, self, & @_oes_p ]

        cm.interpret_compound_component IDENTITY_, nf, self, & _oes_p_
      end
    end

    attr_reader(
      :kernel_,
    )

    class Load_Ticket___

      class << self
        alias_method :__new_via_path, :new
        private :new
      end  # >>

      def initialize path, cr
        @adapter_name = Adapter_Name___.__new_via_path_ path
        @__component_reader = cr
      end

      def adapter
        @cached_adapter ||= ___build_adapter
      end

      def __accept_adapter x
        @cached_adapter = x ; nil
      end

      attr_reader :cached_adapter

      def ___build_adapter
        _cr = remove_instance_variable :@__component_reader
        _cr[ @adapter_name, _component_association.component_model ]
      end

      def _component_association
        @___CA ||= ___build_component_association
      end

      def ___build_component_association
        ACS_[]::Component_Association.via_name_and_model(
          @adapter_name,
          ___component_model,
        )
      end

      def ___component_model

        nf = @adapter_name

        const = nf.as_const
        mod = Home_::Image_Output_Adapters_

        if ! mod.const_defined? const, false
          load nf.path
        end

        mod.const_get const, false
      end

      def as_const
        @adapter_name.as_const
      end

      attr_reader(
        :adapter_name,
      )
    end

    class Adapter_Name___ < Callback_::Name

      def self.__new_via_path_ path

        new do
          @path = path
          bn = ::File.basename path
          init_via_slug bn[ 0 ... - ::File.extname( bn ).length ]
        end
      end

      attr_reader :path
    end
  end
end
