module Skylab::System

  class Filesystem::OperatorBranch_via_Directory < Common_::SimpleModel  # :[#ze-051.G]

    # about the asymmetry of where this stored vs the other [#ze-051]'s:
    #
    # generally the design axiom is that nodes
    # that adapt between a more general and a more specific facility should
    # be closer to the more specific facility. the bulk of the other operator
    # branch adapters are all siblings with each other because they all
    # relate more general ideas (hashes, modules) to the more specific idea
    # of an operator branch (an idea that [ze] officially owns).
    #
    # following that axiom, because a filesystem is more general than [ze],
    # this node should be over there. however, (and whether or not as part
    # of a broader trend) the idea of (something like) an operator branch
    # for directories using filesystem globbing has proven to be useful for
    # sidesystems that inhabit a lower level than [ze], so this one is here.

    # -

      def initialize
        @_item_scanner_mutex = nil
        @_startingpoint_mutex = nil
        yield self
        @filesystem_for_globbing ||= Home_.services.filesystem
        @glob_entry ||= GLOB_STAR_
        @_scn = send @_item_scanner
        @CACHE = {}
        @_open = true
      end

      # ~ you can produce each item (file) using a map or a whole external thing

      def loadable_reference_via_path_by= p
        remove_instance_variable :@_item_scanner_mutex
        @_item_scanner = :__flush_item_scanner_via_mapper
        @__item_map = p
      end

      def __flush_item_scanner_via_mapper
        remove_instance_variable :@_item_scanner
        _p = remove_instance_variable :@__item_map
        Item_scanner_via_mapper___[ _p, self ]
      end

      def item_scanner_by= p
        remove_instance_variable :@_item_scanner_mutex
        @_item_scanner = :__flush_item_scanner_via_proc
        @__item_scanner_by = p
      end

      def __flush_item_scanner_via_proc
        remove_instance_variable :@_item_scanner
        remove_instance_variable( :@__item_scanner_by )[ self ]
      end

      # ~

      def startingpoint_module= x
        remove_instance_variable :@_startingpoint_mutex
        @_startingpoint_path = :__startingpoint_path_derived
        @startingpoint_module = x
      end

      def startingpoint_path= x
        remove_instance_variable :@_startingpoint_mutex
        @_startingpoint_path = :__startingpoint_path_as_is
        @startingpoint_path = x
      end

      attr_writer(
        :glob_entry,
        :filesystem_for_globbing,
      )

      # -- read

      def dereference key_x  # #[#ze-051.1] "trueish item value"
        trueish_x = lookup_softly key_x
        if trueish_x
          trueish_x
        else
          raise ::KeyError
        end
      end

      def lookup_softly key_x  # #[#ze-051.1] "trueish item value"
        x = @CACHE[ key_x.intern ]
        if x
          x
        elsif @_open
          __keep_looking_because_open key_x
        end
      end

      def __keep_looking_because_open key_x

        sym = key_x.intern

        st = _to_remaining_item_stream_DANGEROUS
        begin
          oo = st.gets
          oo || break
          if sym == oo.normal_symbol
            found_oo = oo
            break
          end
          redo
        end while above
        if found_oo
          found_oo
        else
          # hi. #a.s-coverpoint-3
          found_oo
        end
      end

      def to_loadable_reference_stream
        if @_open
          if @CACHE.length.zero?
            _to_remaining_item_stream_DANGEROUS
          else
            __to_item_stream_when_open
          end
        else
          _to_item_stream_using_only_cache
        end
      end

      def __to_item_stream_when_open
        self._README__fun__  # #open [#co-016.1] concatted streams refactor
      end

      def _to_remaining_item_stream_DANGEROUS
        scn = @_scn
        p = -> do
          oo = scn.gets_one
          if scn.no_unparsed_exists
            @_open = false
            remove_instance_variable :@_scn
            p = EMPTY_P_
          end
          @CACHE[ oo.normal_symbol ] = oo
          oo
        end
        if scn.no_unparsed_exists
          p = EMPTY_P_
        end
        Common_::MinimalStream.by do
          p[]
        end
      end

      def _to_item_stream_using_only_cache
        Stream_[ @CACHE.values ]
      end

      def startingpoint_path
        send @_startingpoint_path
      end

      def __startingpoint_path_derived
        @startingpoint_module.dir_path
      end

      def __startingpoint_path_as_is
        @startingpoint_path
      end

      attr_reader(
        :glob_entry,
        :filesystem_for_globbing,
        :startingpoint_module,
      )
    # -
    # ==

    Item_scanner_via_mapper___ = -> map, o do

      _path = o.startingpoint_path

      _glob = ::File.join _path, o.glob_entry

      _paths = o.filesystem_for_globbing.glob _glob

      require 'no-dependencies-zerk'  # ick/meh
      NoDependenciesZerk::Scanner_via_Array.call _paths, & map
    end

    # ==

    GLOB_STAR_ = '*'

    # ==
  end
end
# #history-B, #tombstone-B: moved here from [ze]; a class moved out of here.
# #history: broke out of (now) "one-off" model
