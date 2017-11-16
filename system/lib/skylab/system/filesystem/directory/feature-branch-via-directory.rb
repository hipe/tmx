module Skylab::System

  module Filesystem

    class Directory::OperatorBranch_via_Directory < Common_::SimpleModel

      # "implementation objectives", pseudocode, and historical context in :[#040].

      # as an operator branch, this is referenced with :[#ze-051.7].

    # this operates strictly thru a filesystem controller so it is
    # compatible with a stubbed filesystem.

      def initialize

        @_do_construct_item_scanner_producer = true  # (not method reference so we can yield #here3)
        @_mutex_for_startingpoint = nil

        @item_lemma_symbol = nil

        yield self

        @filesystem_for_globbing ||= Home_.services.filesystem
      end

      # ~ you can produce each item (file) using a map or a whole external thing

      def loadable_reference_via_path_by= p

        _touch_common_item_scanner_producer.__receive_mapper_ p
      end

      def directory_is_assumed_to_exist= yn  # :#here2, exegesis at [#here.D]

        _touch_common_item_scanner_producer.__receive_directory_is_assumed_to_exist_ yn
      end

      def filename_pattern= pat
        _touch_common_item_scanner_producer.__receive_filename_pattern_ pat
      end

      def glob_entry= ge
        _touch_common_item_scanner_producer.__receive_glob_entry_ ge
      end

      def _touch_common_item_scanner_producer
        _touch_item_scanner_producer { CommonItemScannerProducer___ }
      end

      def item_scanner_by= p
        _touch_item_scanner_producer { CustomItemScannerProducer___ }.__receive_proc_ p
      end

      def listener= p  # only used for #here2
        _touch_common_item_scanner_producer.__receive_listener_ p
      end

      def _touch_item_scanner_producer

        if @_do_construct_item_scanner_producer

          @_do_construct_item_scanner_producer = false
          @_mutable_item_scanner_producer = yield.new  # :#here3

          @_read_for_stream = :__read_for_stream_initially
          @_read_for_random_access = :__read_for_random_access_initially
        end

        @_mutable_item_scanner_producer
      end

      # ~

      def startingpoint_module= x
        remove_instance_variable :@_mutex_for_startingpoint
        @_startingpoint_path = :__startingpoint_path_derived
        @startingpoint_module = x
      end

      def startingpoint_path= x
        remove_instance_variable :@_mutex_for_startingpoint
        @_startingpoint_path = :__startingpoint_path_as_is
        @startingpoint_path = x
      end

      attr_writer(
        :descriptive_name_symbol,
        :filesystem_for_globbing,
        :item_lemma_symbol,
      )

      # -- read

      # ~ ACS (legacy)

    # ~~ create (by way of ACS)

    def __add__component qk, & pp

        item = qk.value
        _path = ::File.join startingpoint_path, item.natural_key_string
        listener = pp[ NOTHING_ ]

        _confirm_by = -> do
          # (crazy:)
          item.express_into_under self, @filesystem_for_globbing, & ( -> _ { listener } )
        end

        pdp = @__particular_definition_points

        Directory::AddItem_via_Path.call_by do |o|

          o.path = _path
          o.filename_pattern = pdp.filename_pattern
          o.directory_is_assumed_to_exist = pdp.directory_is_assumed_to_exist
          o.confirm_by = _confirm_by
          o.filesystem = @filesystem_for_globbing
          o.listener = listener
        end
        # (result of above is achieved/unable)
    end

    # ~~ delete (by way of ACS)

    def __remove__component qk, & oes_p_p

      # per ACS, assume that last we checked, item is present in collection
      # this is only exploraory - we emit an event on success

        listener = oes_p_p[ NOTHING_ ]

        _confirm_by = -> do
          ACS_[].send_component_removed qk, self, & listener
          ACHIEVED_
        end

        item = qk.value

        _path = ::File.join startingpoint_path, item.natural_key_string

        _ok = Directory::SoftDeleteItemUsingRename_via_Path.call_by do |o|
          o.path = _path
          o.association = qk.association
          o.filesystem = @filesystem_for_globbing  # cheat a bit
          o.confirm_by = _confirm_by
          o.listener = listener
        end

        _ok && item
    end

    # ~~~ ACS hook-outs *for* edit session (remove if exists, create if not exist)

      # 6
    def expect_component_not__exists__ qk, & oes_p

      _found = first_equivalent_item qk.value
      if _found
        ACS_[].send_component_already_added qk, self, & oes_p
      else
        true
      end
    end

      # 7
    def expect_component__exists__ qk, & oes_p

      _found = first_equivalent_item qk.value
      if _found
        true
      else
        ACS_[].send_component_not_found qk, self, & oes_p
      end
    end

      def first_equivalent_item item

        # (this used to be a #[#ba-051] universal collection operation,
        # but now it is just here so that the above two methods can use
        # their exact legacy implementations as written.
        # #open [#here.F] refactor this after incubation (or just privatize it))

        lookup_softly item.normal_symbol
      end

      # ~

      def procure_by

        Home_.lib_.brazen_NOUVEAU::Magnetics::Item_via_OperatorBranch.call_by do |o|

          o.item_lemma_symbol = @item_lemma_symbol  # can be nil ; do this before below to allow per-call customization

          yield o

          o.operator_branch = self
        end
      end

      def dereference key_x  # #[#ze-051.1] "trueish item value"
        trueish_x = lookup_softly key_x
        if trueish_x
          trueish_x
        else
          raise KeyError, __say( key_x )
        end
      end

      def __say k
        _path = startingpoint_path
        "no file corresponding to '#{ k }' in directory - #{ _path }"
      end

      # -- THE MAIN STUFF (near [#here.C] pseudocode)

      def lookup_softly ref  # #[#ze-051.1] "trueish item value"
        send @_read_for_random_access, ref.intern
      end

      def to_symbolish_reference_scanner
        send( @_read_for_stream ).flush_to_NO_DEPS_ZERK_scanner
      end

      def to_loadable_reference_stream
        send @_read_for_stream
      end

      def __read_for_stream_initially
        _transition_to_hybrid_state_or_the_other_one
        send @_read_for_stream
      end

      def __read_for_random_access_initially k
        _transition_to_hybrid_state_or_the_other_one
        send @_read_for_random_access, k
      end

      def _transition_to_hybrid_state_or_the_other_one  # assume..

        # assume a read will happen immedately after this call.

        _ada = remove_instance_variable :@_mutable_item_scanner_producer

        scn, @__particular_definition_points =
          _ada._flush_to_non_caching_item_scanner_and_readable_definition_points_ self

        if scn.no_unparsed_exists
          @_read_for_random_access = :__read_for_random_access_for_empty_life
          @_read_for_stream = :__read_for_stream_for_empty_life
        else

          @_box_for_hybrid_state = Common_::Box.new
          @_scanner_for_hybrid_state = scn
          @_still_in_hybrid_state = true

          @_read_for_random_access = :__read_for_random_access_in_hybrid_state
          @_read_for_stream = :__read_for_stream_in_hybrid_state
        end
        NIL
      end

      def __read_for_random_access_for_empty_life k
        NOTHING_
      end

      def __read_for_stream_for_empty_life
        The_empty_stream_for_real___[]  # #here5
      end

      def __read_for_random_access_in_hybrid_state k

        # assume mutable cache is started and scanner is non-empty

        item = @_box_for_hybrid_state[ k ]
        if item
          item
        else
          __read_for_random_access_in_hybrid_state_when_not_in_cache k
        end
      end

      def __read_for_random_access_in_hybrid_state_when_not_in_cache k

        st = _to_PRIVATE_stream_OF_AS_YET_UNCACHED_ITEMS_in_hybrid_state

        begin
          item = st.gets
          item || break
          item.normal_symbol == k ? break : redo
        end while above

        item
      end

      def __read_for_stream_in_hybrid_state

        # exegesis at [#here.D]

        offset_of_item_to_see = -1
        the_one_scanner = @_scanner_for_hybrid_state

        main = nil ; go_to_crazy_town = nil

        p = -> do
          if @_still_in_hybrid_state
            main[]
          else
            go_to_crazy_town[]
          end
        end

        main = -> do

          offset_of_item_to_see += 1

          case offset_of_item_to_see <=> @_box_for_hybrid_state.length

          when -1  # when this scanner is behind the cache

            @_box_for_hybrid_state.at_offset offset_of_item_to_see

          when 0  # when this scanner is neck-and-neck with the cache

            item = the_one_scanner.gets_one
            _cache item
            if the_one_scanner.no_unparsed_exists
              _CLOSE
              p = EMPTY_P_
            end

            item
          else

            # how could this scanner ever be ahead of the cache? something is wrong

            self._NEVER__we_cant_imagine_when_this_would_happen
          end
        end

        go_to_crazy_town = -> do
          bx = @_box_for_fully_cached_state
          len = bx.length
          p = -> do
            offset_of_item_to_see += 1
            if len == offset_of_item_to_see
              p = EMPTY_P_ ; NOTHING_
            else
              bx.at_offset offset_of_item_to_see
            end
          end
          p[]
        end

        Common_.stream do  # (stay close to #here5)
          # (upgraded from minimal stream for [tm])
          p[]
        end
      end

      def _to_PRIVATE_stream_OF_AS_YET_UNCACHED_ITEMS_in_hybrid_state

        the_one_scanner = @_scanner_for_hybrid_state

        p = -> do
          item = the_one_scanner.gets_one
          _cache item

          if the_one_scanner.no_unparsed_exists
            _CLOSE
            p = EMPTY_P_
          end

          item
        end

        Common_::MinimalStream.by do
          p[]
        end
      end

      def _cache item
        @_box_for_hybrid_state.add item.normal_symbol, item
        NIL
      end

      def _CLOSE
        _bx = remove_instance_variable :@_box_for_hybrid_state
        @_box_for_fully_cached_state = _bx.freeze
        remove_instance_variable :@_scanner_for_hybrid_state
        @_still_in_hybrid_state = false

        @_read_for_random_access = :__read_for_random_access_in_fully_closed_state
        @_read_for_stream = :__read_for_stream_in_fully_closed_state
        freeze
        NIL
      end

      def __read_for_random_access_in_fully_closed_state sym
        @_box_for_fully_cached_state[ sym ]
      end

      def __read_for_stream_in_fully_closed_state
        @_box_for_fully_cached_state.to_value_stream
      end

      # -- easy reads

      def startingpoint_path
        send @_startingpoint_path
      end

      def __startingpoint_path_derived
        @startingpoint_module.dir_path
      end

      def __startingpoint_path_as_is
        @startingpoint_path
      end

      # ~ ACS (again)

    def to_model_name  # :[#008.2]: #borrow-coverage from [sn] (it's for same)
        Common_::Name.via_lowercase_with_underscores_symbol @descriptive_name_symbol
    end

    def description_under expag  # for [#ac-007.8]
        @descriptive_name_symbol.id2name.gsub UNDERSCORE_, SPACE_  # meh
    end

    def name  # also for [#ac-007.8]
      NOTHING_
    end

      attr_reader(
        :filesystem_for_globbing,  # #here1
        :glob_entry,  # #here1
        :startingpoint_module,

      )
    # -

      # ==

      class CommonItemScannerProducer___

        # this guy must NOT worry about caching

        def initialize
          @__mutex_for_filename_pattern = nil
          @__mutex_for_glob_entry = nil
          @__mutex_for_mapper = nil
          @_knows_whether_or_not_directory_is_assumed_to_exist = false

          @filename_pattern = nil
          @glob_entry = nil
        end

        def __receive_mapper_ p
          remove_instance_variable :@__mutex_for_mapper
          @mapper = p
        end

        def __receive_directory_is_assumed_to_exist_ yn
          @_knows_whether_or_not_directory_is_assumed_to_exist = true
          @_DiAtE_knownness = Common_::KnownKnown.yes_or_no yn ; yn
        end

        def __receive_filename_pattern_ p
          remove_instance_variable :@__mutex_for_filename_pattern
          @filename_pattern = p
        end

        def __receive_glob_entry_ ge
          remove_instance_variable :@__mutex_for_glob_entry
          @glob_entry = ge
        end

        def __receive_listener_ p
          @__listener = p
        end

        # -- read (once)

        def _flush_to_non_caching_item_scanner_and_readable_definition_points_ o

          a = ::Array.new 2

          a[0] = __flush_non_caching_item_scanner o

          if remove_instance_variable :@_knows_whether_or_not_directory_is_assumed_to_exist
            _kn = remove_instance_variable :@_DiAtE_knownness
          end

          a[1] = TheseParticularDefinitionPoints___.new(
            _kn,
            remove_instance_variable( :@filename_pattern ),
          )
          remove_instance_variable :@_FS
          remove_instance_variable :@startingpoint_path
          freeze
          a
        end

        def __flush_non_caching_item_scanner o  # :#here1
          @_FS = o.filesystem_for_globbing
          @startingpoint_path = o.startingpoint_path
          if @_knows_whether_or_not_directory_is_assumed_to_exist && ! @_DiAtE_knownness.value
            if @_FS.directory? @startingpoint_path
              _do_flush_to_non_caching_scanner
            else
              __when_directory_does_not_exist
            end
          else
            _do_flush_to_non_caching_scanner
          end
        end

        def _do_flush_to_non_caching_scanner

          map = remove_instance_variable :@mapper  # user must provide one

          _glob = ::File.join @startingpoint_path, ( @glob_entry || GLOB_STAR_ )
          paths = @_FS.glob _glob

          rx = @filename_pattern
          if rx

            Stream_[ paths ].map_reduce_by do |path|
              if rx =~ ::File.basename( path )
                map[ path ]
              end
            end.flush_to_scanner

          else
            # (we are using "no deps" scanner because the [co] one doesn't map)
            No_deps_zerk_[]::Scanner_via_Array.call paths, & map
          end
        end

        def __when_directory_does_not_exist

          _x = Home_::Filesystem::Normalizations::ExistentDirectory.via(
            :path, @startingpoint_path,
            :filesystem, @_FS,
            & @__listener
          )
          UNABLE_ == _x or self._SANITY
          Common_::THE_EMPTY_SCANNER
        end
      end

      # ==

      class TheseParticularDefinitionPoints___

        # (straightforward, read-only select subset of "definition datapoints")

        def initialize kn, pat
          if kn
            yes = true
            @_DiAtE_knownness = kn
          end
          @knows_whether_or_not_directory_is_assumed_to_exist = yes
          @filename_pattern = pat
          freeze
        end

        def directory_is_assumed_to_exist
          @_DiAtE_knownness.value
        end

        attr_reader(
          :filename_pattern,
          :knows_whether_or_not_directory_is_assumed_to_exist,
        )
      end

      # ==

      class CustomItemScannerProducer___

        def __receive_proc_ p
          @proc = p
        end

        def _flush_to_non_caching_item_scanner_and_readable_definition_points_ o

          _scn = remove_instance_variable( :@proc )[ o ]

          [ _scn, MY_THE_EMPTY_STRUCT___ ]
        end
      end

      # ==

      module MY_THE_EMPTY_STRUCT___ ; class << self
        # (also seen at [#fi-006.2])
        # ..
      end ; end

      The_empty_stream_for_real___ = Lazy_.call do

        # at writing THE_EMPTY_MINIMAL_STREAM does not subclass
        # ::Proc and would need to to pass [tmx] tests

        Common_.stream do
          NOTHING_
        end
      end

      # ==

      ACS_ = Lazy_.call do
      Home_.lib_.arc
      end

      # ==

      GLOB_STAR_ = '*'
      KeyError = ::Class.new ::KeyError

      # ==

    end
  end
end
# #history-A: full rewrite to assimilate newer into older
