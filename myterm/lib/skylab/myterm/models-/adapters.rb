module Skylab::MyTerm

  class Models_::Adapters  # notes in [#003]

    # whereas component associations are typically defined by special
    # methods, we express adapters as components whose associations are
    # represented by the filesystem.

    # -- Construction methods

    class << self

      def interpret_compound_component p, acs, & x_p
        p[ new acs, & x_p ]
      end

      private :new
    end  # >>

    # -- Initializers

    def initialize acs, & p

      @_cached_adapter_instances = nil
      @kernel_ = acs.kernel_
      @_oes_p = p
    end

    # -- ACS hook-ins

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

    def accept_component_qualified_knownness qkn

      # write a component value (presumably from unserialization)

      h = ( @_cached_adapter_instances ||= {} )

      k = qkn.name.as_const

      x = qkn.value_x
      x or self._SANITY

      did = false
      h.fetch k do
        did = true
        h[ k ] = x
      end

      did or self._SANITY

      NIL_
    end

    def component_association_reader  # assume from above

      -> const do
        @_cache.cached( const ).component_association
      end
    end

    def component_wrapped_value asc

      # from above, if for example serialization wants to know if there's
      # anything that needs serializing in this slot, well it's up to us:

      h = @_cached_adapter_instances
      if h
        x = h[ asc.name.as_const ]
        if x
          Callback_::Known_Known[ x ]
        end
      end
    end

    # -- ACS signal handling

    def component_event_model
      :hot
    end

    def receive_component__mutated__ acs, & linked_list_p

      # currently we cache every adapter we ever build, and each of those
      # will (in theory) be produced when we deliver components to be
      # persisted (#here).
      #
      # if we ever want to change this so they "become attached" only when
      # they have peristent data (and become detached for the oppposite),
      # we could do it here.

      @_cached_adapter_instances.fetch acs.name.as_const  # sanity

      # like in a `change` signal, we want our payload to express ourselves,
      # in case the listener isn't already storing us and wants to in case
      # of mutation. but also, we want to propagate the above event ..

      @_oes_p.call :event_and_mutated do
        [ linked_list_p, self ]
      end
    end

    def receive_component__error__ _asc, desc_sym, & ev_p

      # adapter component can add its component as context. add none here.

      @_oes_p.call :error, desc_sym, & ev_p
    end

    def receive_component__info__ _asc, * one_or_two, & y_p

      # informational events from components are propagated as-is. no context.

      @_oes_p.call :info, * one_or_two, & y_p
    end

    # -- Project hook-outs

    def all_to_stream__

      _st = _cache.to_value_stream
      _st.map_reduce_by( & method( :adapter_for_load_ticket_ ) )
    end

    def adapter_for_load_ticket_ lt

      wv = ___cached_value_for_load_ticket lt
      if wv
        # nil OK - if adapter didn't want to load once, don't ask again
        wv.value_x
      else
        __build_and_cache_adapter_for_load_ticket lt
      end
    end

    def ___cached_value_for_load_ticket lt

      h = @_cached_adapter_instances
      if h
        had = true
        x = h.fetch lt.adapter_name.as_const do
          had = false
        end
      end
      if had
        Callback_::Known_Known[ x ]  # might be nil
      end
    end

    def __build_and_cache_adapter_for_load_ticket lt

      # assume all adapters are "entitesque" and never "primitive-esque".

      _ca = lt.component_association

      x = ACS_[]::Interpretation::Build_empty_hot[ _ca, self ]

      _const = lt.adapter_name.as_const

      ( @_cached_adapter_instances = {} )[ _const ] = x  # nil OK

      x
    end

    attr_reader(
      :kernel_,
    )

    # -- Support

    def _cache
      @_cache ||= @kernel_.silo( :Adapters ).cache
    end

    class Silo_Daemon

      # -- The Load Ticket Cache --

      # this "silo daemon" maintains a cache of "load tickets". a "load
      # ticket" is an object that produces "pieces" of an adapter on-demand,
      # lazily. (see #more-about-conservancy.) these pieces are:
      #
      #   • the "adapter name" - an ordinary name function plus
      #     a filesystem "path" member (abstraction candidate).
      #
      #     (this feels near to [#ca-030] "boxxy" but we re-write aspects of
      #      that customly to handle any special needs present or future.)
      #
      #   • the "component association" - like any other component
      #     association, this one associates the adapter name with the
      #     component model (in these cases the adapter front class).
      #
      # any load ticket cannot cache the adapter instance itself because
      # load tickets are "cold" and adapter instances are "hot". see
      # #more-about-hot-cold.

      def initialize ke, _mod
        @kernel_ = ke
      end

      cache = nil  # DEATHWISH  # until we mock something

      define_method :cache do
        cache ||= ___build_cache
      end

      def ___build_cache

        # ridiculous experiment - index the filesystem listing like the
        # autoloader does but do it in a streaming manner, not all at once ..

        _st = ___build_path_classifications_stream

        _st_ = _st.map_by do | cx |
          Load_Ticket___.new cx
        end

        _st_.flush_to_immutable_with_random_access_keyed_to_method :as_const
      end

      def ___build_path_classifications_stream

        _paths = ___paths_via_filesystem_and_glob

        all_path_st = Callback_::Stream.via_nonsparse_array _paths

        dir_queue = []
        file_queue = []
        seen = {}

        Callback_.stream do

          begin

            if file_queue.length.nonzero?
              x = file_queue.shift
              break
            end

            if dir_queue.length.zero?
              path = all_path_st.gets
              path or break
              cx = Path_Classifications__.new path

              if cx.looks_like_file
                seen[ cx.normal ] = true
                x = cx
                break
              end
            else
              cx = dir_queue.shift
              path = cx.path
            end

            # current path looks like directory. if seen match already, skip

            if seen[ cx.normal ]
              redo
            end

            # find any next file that looks like a match. if found, done.
            # if not, assume corefile. queue many things. eek

            begin
              path_ = all_path_st.gets
              if ! path_
                cx.mutate_by_guessing
                x = cx
                break
              end
              cx_ = Path_Classifications__.new path_
              if cx_.looks_like_file
                seen[ cx_.normal ] = true
                if cx.normal == cx_.normal
                  x = cx_
                  break
                end
                file_queue.push cx_
                redo
              end

              # current path looks like directory also. add it to the
              # dir queue for the future and try again.

              dir_queue.push cx_

              redo
            end while nil
            x and break
            redo
          end while nil
          x
        end
      end

      def ___paths_via_filesystem_and_glob

        _fs = @kernel_.silo( :Installation ).filesystem

        _ = "#{ Home_::Image_Output_Adapters_.dir_pathname.to_path }/[a-z0-9]*"

        _fs.glob _
      end
    end  # end of silo daemon

    class Path_Classifications__

      def initialize path
        @path = path

        d = ::File.extname( path ).length

        if d.zero?
          @normal = path
        else
          @looks_like_file = true
          @normal = path[ 0 ... - d ]
        end
      end

      def mutate_by_guessing
        @guessed_path = "#{ @path }/#{ Callback_::Autoloader.default_core_file }"
        NIL_
      end

      attr_reader :guessed_path, :looks_like_file, :normal, :path
    end

    class Load_Ticket___

      def initialize cx

        @adapter_name = Adapter_Name___.new cx
        @_normpath = cx.normal
      end

      def component_association
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

        if mod.const_defined? const, false
          mod.const_get const, false
        else
          load nf.path
          x = mod.const_get const, false
          Autoloader_[ x, @_normpath ]
          x
        end
      end

      def as_const
        @adapter_name.as_const
      end

      attr_reader(
        :adapter_name,  # NOT `name` - it can do more than just a name
      )
    end

    class Adapter_Name___ < Callback_::Name

      def self.new cx

        _path = if cx.looks_like_file
          cx.path
        else
          cx.guessed_path
        end

        super() do
          @path = _path
          init_via_slug ::File.basename cx.normal
        end
      end

      attr_reader :path
    end
  end
end
