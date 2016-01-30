module Skylab::Autonomous_Component_System

  class ReaderWriter  # see [#022] for theory

    # central structure for caching whatever we *do* cache about an ACS,
    # like each of our determinations of whether or not the hook-in is
    # employed for various "axiomatic operations" (and if so, we cache
    # the "reader" or equivalent)..

    class << self
      alias_method :for_componentesque, :new
      private :new
    end  # >>

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
    end

    BUILD_CACHED_ITEM___ = {
      _detect_association_definition_: :__build_detect_etc,
      _method_index_: :__build_method_index,
      _read_association_: :__build_read_association,
      _read_value_: :__build_value_reader,
      _to_node_streamer_: :__build_to_node_streamer,
      _write_value_: :__build_value_writer,
    }

    CUSTOM_METHOD__ = {
      _read_association_: :component_association_reader,
      _read_value_: :component_value_reader,
      _to_node_streamer_: :to_component_node_streamer,
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
        @ACS_.send m  # NOTE - the result is a "reader", i.e a proc-like
      else
        Component_Association.reader_of_component_associations_by_method_in @ACS_
      end
    end

    # -

    def to_node_streamer
      @_cached[ :_to_node_streamer_ ].call
    end

    def __build_to_node_streamer

      m = CUSTOM_METHOD__.fetch :_to_node_streamer_
      if @ACS_.respond_to? m
        @ACS_.method m
      else
        -> do
          Home_::Reflection::Node_Streamer.via_reader__ self
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
