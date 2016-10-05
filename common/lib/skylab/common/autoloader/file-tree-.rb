module Skylab::Common

  module Autoloader

    class FileTree_

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

          sm = _ft.value_state_machine_via_head _slug
          if sm
            eg = sm.entry_group
            if eg.includes_what_is_probably_a_directory
              _make_my_own_tree
            else
              ::Kernel._C
            end
          else
            # (maybe only to cover legacy)
            ::Kernel._B
          end
        end

        def _make_my_own_tree
          _treer = @treerer.call
          _treer[ @module.dir_path ]
        end
      end

      # ==

      do_debug = true
      output_for_trace = nil

      Cache = -> fs do

        # build a new file tree cache (typically a singleton)

        h = {}
        p = -> node_path do
          h.fetch node_path do
            if do_debug
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
        serr = $stderr

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
            FilesystemHit___.new @_h_, @_a, @_h, @node_path, @treer
          else
            send @_when_failed
          end
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
            @_a = [] ; @_h = {} ; @_h_ = {}
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

            @_h_[ Distill_[ k ] ] = k

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

      FilesystemHit___ = self

      class FilesystemHit___

        def initialize h_, a, h, s, treer

          @_a = a ; @_h = h
          @__head_via_approximation = h_
          @node_path = s
          @_value_state_machine_cache = {}
          @treer = treer
          freeze
        end

        def child_file_tree sm  # state machine

          _child_node_path = ::File.join @node_path, sm.entry_group.head

          @treer[ _child_node_path ]
        end

        def corefile_state_machine
          value_state_machine_via_approximation CORE_KEY___
        end

        CORE_KEY___ = CORE_ENTRY_STEM.intern

        def to_state_machine_stream
          _ = to_state_machine_stream_proc_
          _ = Home_.stream( & _ )
        end

        def to_state_machine_stream_proc_
          d = -1 ; head_a = @_a ; last = head_a.length - 1
          -> do
            if last != d
              d += 1
              _value_state_machine_via_head head_a.fetch d
            end
          end
        end

        def value_state_machine_via_approximation k

          head = @__head_via_approximation[ k ]
          if head
            _value_state_machine_via_head head
          end
        end

        def value_state_machine_via_head head

          entry_group = @_h[ head ]
          if entry_group
            @_value_state_machine_cache.fetch head do
              _add_and_produce_state_machine entry_group, head
            end
          end
        end

        def _value_state_machine_via_head head
          @_value_state_machine_cache.fetch head do
            _add_and_produce_state_machine @_h.fetch( head ), head
          end
        end

        def _add_and_produce_state_machine entry_group, head

          sm = ValueStateMachine___.new entry_group, @node_path
          @_value_state_machine_cache[ head ] = sm
          sm
        end

        def is_file_tree
          true
        end

        attr_reader(
          :node_path,  # maybe just debugging
        )
      end

      # ==

      class ValueStateMachine___

        def initialize eg, node_path

          @entry_group = eg
          @parent_node_path = node_path
          @value_is_known = false
        end

        def write_value__ x, sym
          @_value_and_name = Pair.via_value_and_name x, sym
          @value_is_known = true
          freeze
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
