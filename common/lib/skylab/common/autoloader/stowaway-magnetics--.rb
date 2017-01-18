module Skylab::Common

  module Autoloader

    StowawayMagnetics__ = ::Module.new  # notes in [#031]

    StowawayMagnetics__::NameAndValue_via_ConstMissing = -> cm do

      stow_x = cm.module.stowaway_hash_.fetch cm.const_symbol  # a given
      if stow_x.respond_to? :ascii_only?
        NameAndValue_via_PathBased___.new( stow_x, cm ).execute
      else
        NameAndValue_via_ProcBased___[ stow_x, cm ]
      end
    end

    NameAndValue_via_ProcBased___ = -> stow_x, cm do
      # -

        mod = cm.module
        const = cm.const_symbol

        x = stow_x.call

        if mod.const_defined? const, false

          # if you define the value in the block yourself, then we use that

          x = mod.const_get const, false
        else

          # otherwise we use the result value, and do this:

          mod.const_set const, x
        end

        # we do *not* autoloaderize - do it yourself if you want it
        # we do *not* associate the value w/ a filesystem node

        Known_Known[ x ]
      # -
    end

    class NameAndValue_via_PathBased___

      # #note-1 - how string-based stowaway specifiers are interpreted
      # #note-2 - the autoloaderization contract when stowing away

      def initialize path_tail, cm
        @client = cm
        @path_tail = path_tail
      end

      def execute
        __for_each_path_tail_item_step_down_the_filesystem_tree
        __load_the_file
        __autoloaderize_the_host_asset
        __known_of_the_guest_asset
      end

      def __for_each_path_tail_item_step_down_the_filesystem_tree

        __init_for_loop

        st = __stream_via_path_tail_pieces

        frame = __first_frame_via st

        until st.no_unparsed_exists

          _see frame

          frame = frame.next_frame st.gets_one
        end

        _see frame

        @_final_frame = frame
        NIL
      end

      def __load_the_file

        @client.load_path = @_final_frame.__some_load_file_path
        @client.load_the_file_
        NIL
      end

      def __autoloaderize_the_host_asset

        scn = Scanner.via_array @_frames

        fr = InferenceFrame__.new scn.gets_one, @client.module

        begin
          if scn.no_unparsed_exists
            fr.init_and_cache_and_autoloaderize_terminal_node
            break
          end
          fr.init_and_cache_and_autoloaderize_nonterminal_node
          scn.no_unparsed_exists && break
          fr = fr.next_frame scn.gets_one
          redo
        end while above

        NIL
      end

      def __known_of_the_guest_asset
        o = @client
        o.become_loaded_assuming_assets_are_loaded_
        o.to_known_
      end

      def __init_for_loop
        @_frames = []
        @__path_tail_pieces = @path_tail.split ::File::SEPARATOR
        @_pieces = []
        NIL
      end

      def __first_frame_via st

        _piece = st.gets_one  # implicit assertion of nonzero-length

        _file_tree = @client.module.entry_tree

        FilesystemNodeFrame__.new _piece, _file_tree
      end

      def _see frame
        @_frames.push frame
        @_pieces.push frame.piece_string
        NIL
      end

      def __stream_via_path_tail_pieces
        Scanner.via_array @__path_tail_pieces
      end
    end

    # ==

    class NameAndValue_via_PathBased___::InferenceFrame__

      def initialize fs_frame, mod
        @frame = fs_frame
        @module = mod
      end

      def next_frame fs_frame
        if ! Is_probably_module[ @_the_value ]
          self._COVER_ME_expected_module
        end
        NameAndValue_via_PathBased___::InferenceFrame__.new fs_frame, @_the_value
      end

      # ~

      # the host file for the stowaway implies a host node (i.e a value
      # reachable by a fully qualified const). if that host node is already
      # defined when we get here, then it's reasonable to assume that the
      # host file had already been loaded. if that's the case then the
      # stowaway(s) that were in that file should already be loaded too
      # so autoloading should never have triggered for the target node, so
      # something's wrong. the assertion raised #here checks this.
      #
      # but note this assumption only holds for the *terminal* node of
      # a host node. under some circumstances it's possible for the
      # nonterminal nodes to already be defined when we get here. in those
      # cases we check for this and avoid redundantly autoloaderizing them.
      # (this additional detail was (re-?) added at #tombstone-B)

      def init_and_cache_and_autoloaderize_terminal_node
        _init_and_cache_and_autoloaderize_or_if_value_is_known do
          self._WHERE  # #here
        end
        NIL
      end

      def init_and_cache_and_autoloaderize_nonterminal_node
        _init_and_cache_and_autoloaderize_or_if_value_is_known do
          NOTHING_
        end
        NIL
      end

      def _init_and_cache_and_autoloaderize_or_if_value_is_known
        @_state_machine = @frame.state_machine
        if @_state_machine.value_is_known
          yield
          @_the_value = @_state_machine.value_x
        else
          __init_and_cache_and_autoloaderize
        end
      end

      def __init_and_cache_and_autoloaderize
        __init_value_via_inference
        __cache
        __maybe_autoloaderize
      end

      # ~

      def __maybe_autoloaderize

        if __should_autoloaderize_the_value

          _path = @_state_machine.get_node_path
          Here_[ @_the_value, _path, :autoloaderized_parent_module, @module ]
          NIL
        else
          NIL  # covered obliquely
        end
      end

      def __should_autoloaderize_the_value  # a near copy-paste of #spot-4

        if @_state_machine.entry_group.includes_what_is_probably_a_directory

          if Is_probably_module[ @_the_value ]

            ! @_the_value.respond_to? NODE_PATH_METHOD_
          end
        end
      end

      def __cache
        @PAIR = @_state_machine.write_and_produce_pair_ @_the_value, @_const
        NIL
      end

      def __init_value_via_inference

        if __const_is_defined_when_camelcase
        elsif __const_is_defined_when_wide_camelcase
        elsif __const_is_defined_when_all_caps
        else __big_guns
        end
        @_the_value = @module.const_get @_const, false
        NIL
      end

      def __const_is_defined_when_camelcase
        @_name = Name.via_slug @frame.piece_string
        _attempt_const @_name.as_camelcase_const_string
      end

      def __const_is_defined_when_wide_camelcase
        @_wide_const = @_name.as_const
        _attempt_const @_wide_const
      end

      def __const_is_defined_when_all_caps
        _attempt_const @_wide_const.upcase
      end

      def _attempt_const const_x
        if @module.const_defined? const_x, false
          @_const = const_x.intern ; ACHIEVED_
        end
      end

      def __big_guns
        o = Here_::FuzzyLookup_.new
        o.on_exactly_one = IDENTITY_
        @_const = o.execute_for @module, @_name
        NIL
      end

      attr_reader(
        :frame,  # #todo
        :module, # #todo
      )
    end

    # ==

    class NameAndValue_via_PathBased___::FilesystemNodeFrame__

      def initialize piece, file_tree
        @piece_string = piece
        @file_tree = file_tree
      end

      def next_frame piece

        sm = state_machine

        if sm.entry_group.includes_what_is_probably_a_directory

          _file_tree_ = @file_tree.child_file_tree sm

          NameAndValue_via_PathBased___::FilesystemNodeFrame__.new piece, _file_tree_
        else
          self._HOLE_intermediate_tail_piece_is_not_directory
        end
      end

      def __some_load_file_path
        load_file = @file_tree.get_load_file_path_for__ @piece_string
        if load_file
          load_file
        else
          self._HOLE_no_load_file_for_final_path_tail_piece
        end
      end

      def state_machine
        @___sm ||= __state_machine
      end

      def __state_machine
        sm = @file_tree.value_state_machine_via_head @piece_string
        if ! sm
          self._COVER_ME_bad_path_tail_piece__no_such_filesystem_node
        end
        sm
      end

      attr_reader(
        :piece_string,
      )
    end
  end
end  # :#sm
# #tombstone-B: added a finer point to autoloaderizing host nodes
# #tombstone: full rewrite
