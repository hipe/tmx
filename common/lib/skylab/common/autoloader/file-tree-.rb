module Skylab::Common

  module Autoloader

    class FileTree_

      # (defined as class #here)

      # ==

      class Via_module

        def initialize mod, treerer
          @module = mod
          @treerer = treerer
        end

        def execute

          # per the central algorithm in [#024], come down from above

          if __my_dir_path_is_already_set

            _make_my_own_tree

          elsif __I_have_a_parent_module

            if __that_parent_module_has_a_file_tree

              __come_downwards_from_the_parent_entry_tree
            else
              _make_my_own_tree
            end
          else
            _make_my_own_tree
          end
        end

        def __my_dir_path_is_already_set

          if @module.instance_variable_defined? NODE_PATH_IVAR_
            @module.instance_variable_get NODE_PATH_IVAR_
          end
        end

        def __I_have_a_parent_module
          mod = @module.parent_module
          if mod
            @_parent_module = mod ; ACHIEVED_
          end
        end

        def __that_parent_module_has_a_file_tree
          if @_parent_module.respond_to? :entry_tree
            ft = @_parent_module.entry_tree
            if ft
              @_parent_file_tree = ft ; ACHIEVED_
            end
          end
        end

        def __come_downwards_from_the_parent_entry_tree
          # the reason we do this is because [#058] #note-3

          _existed = @module.pedigree_
          _name = _existed.node_path_entry_name_
          _slug = _name.as_slug

          _ft = @_parent_file_tree

          at = _ft.asset_ticket_via_entry_group_head _slug
          if at
            eg = at.entry_group
            if eg.includes_what_is_probably_a_directory
              _make_my_own_tree
            else
              NOTHING_  # as covered, this value will be memoized
            end
          else
            NOTHING_  # as covered, (ditto)
          end
        end

        def _make_my_own_tree
          _treer = @treerer.call
          _treer[ @module.dir_path ]
        end
      end

      # ==

      output_for_trace = nil

      Cache = -> fs do

        # build a new file tree cache (typically a singleton)

        h = {}
        p = -> node_path do
          h.fetch node_path do
            if DO_DEBUG_
              output_for_trace[ node_path ]
            end
            node = FileTree_via_NodePath___.new( node_path, p, fs ).execute
            h[ node_path ] = node
            node
          end
        end
        p
      end

      output_for_trace = -> path0 do

        # paths that are in a file that are in an installed gem have leading
        # cruft we want to ellipsify from every but the first such occurrence.
        # detect the first such path hackishly, and then use this path somehow
        # to decide how to detect and shorten subsequent such paths. exploratory

        gem_needle = ::File.join EMPTY_S_, 'ruby', RUBY_VERSION, 'gems', EMPTY_S_
        margin = "#{ SPACE_ * 18 } * "
        sep = ::File::SEPARATOR
        serr = DEBUG_IO_

        puts = -> line do
          serr.puts "#{ margin }#{ line }"
        end

        rx = /\d+(?:\.\d+)+\.(?<short_part>[a-z]+)/

        rx_ = /\A#{ ::File.join EMPTY_S_, 'lib', 'skylab', '[a-z_]+' }(?:#{ sep }(?<rest>.+))?/

        output_for_trace = -> path1 do
          puts[ path1 ]
          d = path1.index gem_needle
          if d
            midpoint = d + gem_needle.length
            head_range = 0 ... midpoint
            tail_range = midpoint .. -1
            head_needle = path1[ head_range ]
            output_for_trace = -> path do
              if head_needle == path[ head_range ]
                shorter = path[ tail_range ]
                d = shorter.index sep
                gemdir = shorter[ 0, d ]
                md = rx.match gemdir
                if md
                  gem_local_path = shorter[ d .. -1 ]
                  md_ = rx_.match gem_local_path
                  if md_
                    s = md_[ :rest ]
                    gem_local_path = ( " #{ s }" if s )
                  end
                  puts[ "[#{ md[ :short_part ] }]#{ gem_local_path }" ]
                else
                  puts[ "[..]/#{ shorter }" ]
                end
              else
                puts[ path ]
              end
            end
          end
        end
        output_for_trace[ path0 ]
      end

      # ==

      class FileTree_via_NodePath___

        def initialize node_path, treer, fs
          @filesystem = fs
          @node_path = node_path
          @treer = treer
        end

        def execute

          __init_index_via_hit_the_filesystem
          if @_ok
            @_a.sort!  # don't let the filesystem determine the order. tests flicker
            FilesystemHit___.new @_a, @_h, @node_path, @treer
          else
            send @_when_failed
          end
        end

        def __when_enoent
          NOTHING_  # as covered. be sure this gets cached. #coverpoint-1-1
        end

        def __init_index_via_hit_the_filesystem
          p = nil
          main = -> entry do
            md = RX___.match entry
            if md
              __add_match md
            end
          end
          dot_dot = -> entry do
            DOT_DOT_ == entry || self._SANIY
            p = main
          end
          p = -> entry do
            @_a = [] ; @_h = {}
            DOT_ == entry || self._SANITY
            p = dot_dot
          end
          __each_entry do |entry|
            p[ entry ]
          end
          NIL
        end

        def __each_entry  & p
          @_ok = true
          @filesystem.foreach @node_path, & p
          NIL
        rescue ::Errno::ENOENT => @_exception
          @_ok = false
          @_when_failed = :__when_enoent
          NIL
        rescue ::Errno::ENOTDIR => @_exception
          @_ok = false
          @_when_failed = :__when_enotdir
          NIL
        end

        same_rsx = '[a-z][-a-z0-9]*'

        RX___ = /\A
          (?:
            (?<looks_like_file> #{ same_rsx } ) #{ ::Regexp.escape EXTNAME }
          |
            (?: #{ same_rsx } )
          )
        \z/ix

        def __add_match md

          head = md[ :looks_like_file ]
          if head
            k = head
            looks_like_file = true
          else
            k = md.string
          end

          existing = @_h.fetch k do

            @_a.push k

            ent = if looks_like_file
              ProbablyFile___.new k, md.string
            else
              ProbablyDirectory___.new k
            end

            @_h[ k ] = ent
            NIL
          end

          if existing
            _ent = if looks_like_file
              existing.upgrade_to_both_via_probably_file md.string
            else
              existing.upgrade_to_both_because_probably_directory
            end
            @_h[ k ] = _ent
          end
          NIL
        end
      end

      # ==

      FilesystemHit___ = self  # :#here

      class FilesystemHit___

        def initialize a, h, s, treer

          @_a = a ; @_h = h
          @node_path = s
          @_value_asset_ticket_cache = {}
          @treer = treer
        end

        def get_load_file_path_for__ head

          at = asset_ticket_via_entry_group_head head
          if at
            get_load_file_path_for_asset_ticket at
          end
        end

        def get_load_file_path_for_asset_ticket at  # [pl]

          if at.entry_group.includes_what_is_probably_a_file
            at.get_filesystem_path
          else
            # (hi.)
            _ft = child_file_tree at
            at_ = _ft.corefile_asset_ticket_
            if at_
              at_.get_filesystem_path
            end
          end
        end

        def child_file_tree at  # state machine

          _child_node_path = ::File.join @node_path, at.entry_group.head

          @treer[ _child_node_path ]
        end

        def corefile_asset_ticket_
          asset_ticket_via_entry_group_head CORE_ENTRY_STEM
        end

        def to_asset_ticket_stream
          _ = to_asset_ticket_stream_proc_
          _ = Home_.stream( & _ )
        end

        def to_asset_ticket_stream_proc_
          d = -1 ; head_a = @_a ; last = head_a.length - 1
          -> do
            if last != d
              d += 1
              dereference_asset_ticket_via_entry_group_head head_a.fetch d
            end
          end
        end

        def asset_ticket_via_approximation_softly__ k

          head = ( @___head_via_approximation ||= __build_approximation_cache )[ k ]
          if head
            dereference_asset_ticket_via_entry_group_head head
          end
        end

        def __build_approximation_cache
          h = {}
          @_h.keys.each do |s|
            h[ Distill[s] ] = s
          end
          h
        end

        def asset_ticket_via_entry_group_head head

          entry_group = @_h[ head ]
          if entry_group
            @_value_asset_ticket_cache.fetch head do
              _add_and_produce_asset_ticket entry_group, head
            end
          end
        end

        def dereference_asset_ticket_via_entry_group_head head  # 1x [ze]
          @_value_asset_ticket_cache.fetch head do
            _add_and_produce_asset_ticket @_h.fetch( head ), head
          end
        end

        def _add_and_produce_asset_ticket entry_group, head

          at = AssetTicketStateMachine___.new entry_group, @node_path
          @_value_asset_ticket_cache[ head ] = at
          at
        end

        attr_reader(
          :node_path,  # maybe just debugging
        )
      end

      # ==

      class AssetTicketStateMachine___

        def initialize eg, node_path
          @entry_group = eg
          @parent_node_path = node_path
          @value_is_known = false
        end

        def write_and_produce_pair_ x, const_sym
          pa = Pair.via_value_and_name x, const_sym
          @value_is_known = true
          @_value_and_name = pa
          freeze
          pa
        end

        def value_x
          @_value_and_name.value_x
        end

        def const_symbol
          @_value_and_name.name_symbol
        end

        def get_node_path
          ::File.join @parent_node_path, @entry_group.head
        end

        def get_filesystem_path
          ::File.join @parent_node_path, @entry_group.filesystem_entry_string
        end

        def entry_group_head
          @entry_group.head
        end

        attr_reader(
          :entry_group,
          :parent_node_path,
          :value_is_known,
        )

        def HELLO_ASSET_TICKET
          # (can probably be removed from universe by the time you read this)
          NIL
        end
      end

      # ==

      class Negative__

        def initialize s
          @filesystem_entry_string = s
        end

        attr_reader(
          :filesystem_entry_string,
        )

        def includes_what_is_probably_a_directory
          false
        end

        def includes_what_is_probably_a_file
          false
        end
      end

      class ProbablyDirectory___ < Negative__

        def upgrade_to_both_via_probably_file with_ext
          ProbablyBoth__.new @filesystem_entry_string, with_ext
        end

        def head
          @filesystem_entry_string
        end

        def includes_what_is_probably_a_directory
          true
        end
      end

      class ProbablyFile___ < Negative__

        def initialize k, s
          @head = k
          super s
        end

        def upgrade_to_both_because_probably_directory
          ProbablyBoth__.new @head, @filesystem_entry_string
        end

        attr_reader(
          :head,
        )

        def includes_what_is_probably_a_file
          true
        end
      end

      class ProbablyBoth__ < Negative__

        def initialize k, s
          @head = k
          super s
        end

        attr_reader(
          :head,
        )

        def includes_what_is_probably_a_directory
          true
        end

        def includes_what_is_probably_a_file
          true
        end
      end
    end
  end
end
# #history: broke out (and heavily refactored) from toplevel sidesys file
