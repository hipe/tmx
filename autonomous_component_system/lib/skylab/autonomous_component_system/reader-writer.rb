module Skylab::Autonomous_Component_System

  class ReaderWriter  # see [#022] for theory

    # central structure for caching whatever we *do* cache about an ACS,
    # like each of our determinations of whether or not the hook-in is
    # employed for various "axiomatic operations" (and if so, we cache
    # the "reader" or equivalent)..

    class << self

      def for_componentesque acs

        # (memoizing the r/w is #experimental, might become opt-out)

        if acs.instance_variable_defined? IVAR__
          acs.instance_variable_get IVAR__
        else
          x = new acs
          acs.instance_variable_set IVAR__, x
          x
        end
      end

      private :new
    end  # >>

    IVAR__ = :@___reader_writer_by_autonomous_component_system

    def initialize acs

      @ACS_ = acs

      cache = {}
      @_cached = -> k do
        cache.fetch k do
          x = send BUILD_CACHED_ITEM___.fetch k
          cache[ k ] = x
          x
        end
      end

      @__clear_cache = -> do
        cache.clear
      end
    end

    def clear_cache  # 1x [ze]
      @__clear_cache.call
    end

    BUILD_CACHED_ITEM___ = {
      _detect_association_definition_: :__build_detect_etc,
      _method_index_: :__build_method_index,
      _read_association_: :__build_read_association,
      _read_formal_operation_: :__build_read_formal_operation,
      _read_value_: :__build_value_reader,
      _to_node_ticket_streamer_: :__build_node_ticket_streamer,
      _write_if_not_set_: :__build_write_if_not_set,
      _write_value_: :__build_value_writer,
    }

    CUSTOM_METHOD__ = {
      _read_association_: :component_association_reader,
      _read_formal_operation_: :component_operation_reader,
      _read_value_: :component_value_reader,
      _to_node_ticket_streamer_: :to_component_node_ticket_streamer,
      _write_value_: :component_value_writer,
    }

    # -

    def read_association k
      @_cached[ :_read_association_ ].call k
    end

    def association_reader  # [sn]
      @_cached[ :_read_association_ ]
    end

    def has_an_association_definition_for name_symbol  # [my]
      @_cached[ :_detect_association_definition_ ][ name_symbol ]
    end

    def __build_detect_etc
      # (no need for customization yet)
      acs = @ACS_
      -> sym do
        m = Component_Association::Method_name_via_name_symbol[ sym ]
        if acs.respond_to? m
          m
        end
      end
    end

    def __build_read_association
      m = CUSTOM_METHOD__.fetch :_read_association_
      if @ACS_.respond_to? m
        @ACS_.send m
      else
        Component_Association.reader_of_component_associations_by_method_in @ACS_
      end
    end

    # -

    def read_formal_operation k
      @_cached[ :_read_formal_operation_ ].call k
    end

    def __build_read_formal_operation
      m = CUSTOM_METHOD__.fetch :_read_formal_operation_
      if @ACS_.respond_to? m
        @ACS_.send m
      else
        Home_::Operation::Formal.reader_of_formal_operations_by_method_in @ACS_
      end
    end

    # -

    def to_non_operation_node_ticket_streamer
      o = to_node_ticket_streamer
      o.on_operation = MONADIC_EMPTINESS_  # operation nodes don't get serialized
      o
    end

    def to_node_ticket_streamer
      @_cached[ :_to_node_ticket_streamer_ ].call
    end

    def __build_node_ticket_streamer

      m = CUSTOM_METHOD__.fetch :_to_node_ticket_streamer_
      if @ACS_.respond_to? m
        @ACS_.method m
      else
        -> do
          Home_::Reflection::Node_Ticket_Streamer.via_reader__ self
        end
      end
    end

    def to_entry_stream__
      _mi = @_cached[ :_method_index_ ]
      _mi.to_entry_stream
    end

    def __build_method_index  # [#003]:"why we cache the method index"
      Home_::Method_Index___.new @ACS_.class.instance_methods false
    end

    # -

    def write_if_not_set qk
      @_cached[ :_write_if_not_set_ ][ qk ]
    end

    def __build_write_if_not_set

      rv = @_cached[ :_read_value_ ]
      wv = @_cached[ :_write_value_ ]

      -> qk do

        kn = rv[ qk ]
        if kn.is_effectively_known
          UNABLE_
        else
          wv[ qk ]
          ACHIEVED_
        end
      end
    end

    def touch_component asc  # #experimental [ze] 1x
      Home_::Interpretation::Touch[ asc, self ]  # qk
    end

    def qualified_knownness_of_association asc
      # assume associated association.

      _kn = read_value asc
      _kn.to_qualified_known_around asc
    end

    def read_value asc
      @_cached[ :_read_value_ ][ asc ]
    end

    def __build_value_reader
      m = CUSTOM_METHOD__.fetch :_read_value_
      if @ACS_.respond_to? m
        @ACS_.send m  # LOOK it produces a reader
      else
        Home_::By_Ivars::Value_reader_in[ @ACS_ ]
      end
    end

    # -

    def write_value qk
      value_writer_[ qk ]
      NIL_
    end

    def value_writer_
      @_cached[ :_write_value_ ]
    end

    def __build_value_writer
      m = CUSTOM_METHOD__.fetch :_write_value_
      if @ACS_.respond_to? m
        @ACS_.send m
      else
        Home_::By_Ivars::Value_writer_in[ @ACS_ ]
      end
    end

    # -

    def ACS  # (look like a stack frame)
      @ACS_
    end

    def reader_writer
      self
    end

    attr_reader(
      :ACS_,
    )
  end
end
