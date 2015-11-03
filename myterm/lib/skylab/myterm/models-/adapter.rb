module Skylab::MyTerm

  class Models_::Adapter

    class << self

      def interpret_component st, & x_p

        if st.no_unparsed_exists
          _new_entity( & x_p )
        else
          o = _new_entity( & x_p )
          ada = o._lookup st.gets_one
          if ada
            ada._accept_selected
            ada
          else
            ada
          end
        end
      end

      alias_method :_new_entity, :new
      private :new
    end  # >>

    def initialize & oes_p  # on event selectively
      @is_selected = false
      @_oes_p = oes_p
    end

    def initialize_component asc, acs

      @_asc = asc
      @_kernel = acs.kernel_
      ACHIEVED_
    end

    # ~ the "set" operation

    def __set__component_operation

      yield :description, -> y do
        y << "set the adapter"
      end

      yield :parameter, :adapter, :description, -> y do
        y << "the name of the adapter to use"
        y << "(see `list` for a list of adapters)"   # etc
      end

      method :__receive_set_adapter_name
    end

    def __receive_set_adapter_name adapter

      ada = _lookup adapter
      if ada
        if object_id == ada.object_id
          # for now we let this slide (covered), just so we can cover the
          # mechanics of it. but follow this up if you want to..
        end
        __receive_set_adapter ada
      else
        ada
      end
    end

    def __receive_set_adapter ada

      if object_id != ada.object_id
        @is_selected = false  # maybe not important
      end

      ada._accept_selected

      @_oes_p.call :component, :change do | y |
        y.yield :new_component, ada
        y.yield :association, @_asc
      end
    end

    def _lookup x

      oes_p = @_oes_p

      o = Brazen_::Collection::Common_fuzzy_retrieve.new( & oes_p )

      _ = Callback_::Qualified_Knownness.via_value_and_symbol x, :adapter

      o.qualified_knownness = _

      o.stream_builder = -> do
        _to_adapter_stream( & oes_p )
      end

      o.name_map = -> ada do
        ada._adapter_name.as_slug
      end

      o.execute
    end

    # ~ the "list" operation

    def __list__component_operation

      yield :description, -> y do
        y << "list the available adapters"
      end

      method :_to_adapter_stream
    end

    # ~ operation support

    def _to_adapter_stream

      # function soup for this: if you are selected and you are providing
      # the list, provide yourself as the appropriate item in the stream.

      build_via_proto = nil

      use_build_via_proto = -> path do
        build_via_proto[ path ]
      end

      if @is_selected
        my_path = @path
        p = -> path do
          if my_path == path
            p = use_build_via_proto
            self
          else
            build_via_proto[ path ]
          end
        end
      else
        p = use_build_via_proto
      end

      build_via_proto = -> x do
        proto = self.class._new_entity( & @_oes_p )
        build_via_proto = -> path do
          proto.new path
        end
        build_via_proto[ x ]
      end

      @__ls ||= ::Dir[ "#{ Home_::Image_Output_Adapters_.dir_pathname.to_path }/[a-z0-9]*" ]

      Callback_::Stream.via_nonsparse_array @__ls do | path |
        p[ path ]
      end
    end

    # ~ as dispatcher to adapter

    def to_particular_node_stream__
      @__ada ||= __build_particular_adapter
      ACS_[]::Reflection::To_node_stream[ @__ada ]
    end

    def __build_particular_adapter

      nf = _adapter_name

      _cls = Home_::Image_Output_Adapters_.const_get( nf.as_const, false )

      _oes_p_ = ACS_[]::Interpretation::Component_handler[ self, & @_oes_p ]

      _cls.new nf, & _oes_p_
    end

    # ~ as entity

    def new path
      otr = dup
      otr.__init path
      otr
    end

    def __init path

      @is_selected = false
      @path = path
      NIL_
    end

    def express_into_under y, _expag  # for a mode client

      _glyph_for_is_selected = if @is_selected
        SELECTED_GLYPH__
      else
        NULL_GLYPH__
      end

      y << "#{ _glyph_for_is_selected }#{ _adapter_name.as_slug }"
    end

    def describe_into_under y, expag  # for reactive tree
      me = self
      expag.calculate do
        y << "#{ me.___operation_symbols * ', ' } adapters"  # etc
      end
    end

    def ___operation_symbols
      ACS_[]::Reflection::Method_index_of_class[ self.class ].operation_symbols
    end

    def description_under expag  # for [#br-035] expressive events
      me = self
      expag.calculate do
        nm me._adapter_name
      end
    end

    def to_component_value
      _adapter_name.as_slug
    end

    def _adapter_name
      @___nf ||= __build_adapter_name_function
    end

    def __build_adapter_name_function

      bn = ::File.basename @path
      Callback_::Name.via_slug bn[ 0 ... - ::File.extname( bn ).length ]
    end

    nf = nil
    define_method :name do  # #open [#br-107] will change this name
      nf ||= Callback_::Name.via_variegated_symbol( :adapter )
    end

    def _accept_selected
      @is_selected = true ; nil
    end

    attr_reader(
      :is_selected,
      :path,
    )

    NULL_GLYPH__ = '  '
    SELECTED_GLYPH__ = '• '
  end
end
