module Skylab::MyTerm

  class Models_::Adapter

    class << self

      def interpret_component arg_st, & x_p

        if arg_st.no_unparsed_exists
          new( & x_p )
        else
          self._DESIGN_ME_syntax_for_creation_for_edit_session
        end
      end

      alias_method :__new_entity, :new

      private :new
    end  # >>

    def initialize & oes_p
      @_on_event_selectively = oes_p
    end

    def describe_into_under y, expag
      me = self
      expag.calculate do
        y << "#{ me.__operation_symbols * ', ' } adapters"  # etc
      end
    end

    def __operation_symbols
      ACS_[]::Reflection::Method_index_of_class[ self.class ].operation_symbols
    end

    def __list__component_operation

      yield :description, -> y do
        y << "list the available adapters"
      end

      method :__to_stream
    end

    def __to_stream & oes_p

      proto = self.class.__new_entity( & oes_p )

      _ = ::Dir[ "#{ Home_::Image_Output_Adapters_.dir_pathname.to_path }/*" ]

      Callback_::Stream.via_nonsparse_array _ do | path |
        proto.new path
      end
    end

    # ~ as entity

    def new path
      otr = dup
      otr.__init path
      otr
    end

    def __init path

      @_is_selected = false
      @path = path
      NIL_
    end

    attr_reader(
      :path,
    )

    nf = nil
    define_method :name do  # #open [#br-107] will change this name
      nf ||= Callback_::Name.via_variegated_symbol( :adapter )
    end

    def express_into_under y, _expag

      _glyph_for_is_selected = if @_is_selected
        SELECTED_GLYPH__
      else
        NULL_GLYPH__
      end

      y << "#{ _glyph_for_is_selected }#{ _adapter_name.as_slug }"
    end

    def _adapter_name
      @___nf ||= __build_adapter_name_function
    end

    def __build_adapter_name_function

      bn = ::File.basename @path
      Callback_::Name.via_slug bn[ 0 ... - ::File.extname( bn ).length ]
    end

    NULL_GLYPH__ = '  '
    SELECTED_GLYPH__ = '• '
  end
end
