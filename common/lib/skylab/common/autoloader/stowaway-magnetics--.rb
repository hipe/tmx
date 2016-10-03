module Skylab::Common

  module Autoloader

    StowawayMagnetics__ = ::Module.new

    StowawayMagnetics__::Value_via_ConstMissing = -> cm do

      stow_x = cm.remove_instance_variable :@stowaway_x__
      if stow_x.respond_to? :ascii_only?
        Value_via_PathBased___[ stow_x, cm ]
      else
        Value_via_ProcBased___[ stow_x, cm ]
      end
    end

    Value_via_ProcBased___ = -> stow_x, cm do
      # -
        sym = cm.const_symbol ; mod = cm.module
        x = stow_x.call
        if ! mod.const_defined? sym, false  # aesthetics - oneline
          mod.const_set sym, x
        end
        # we do *not* autoloaderize - do it yourself if you want it
        cm.cache_and_produce_value_ x
      # -
    end

    class Value_via_PathBased___ < Home_::Actor::Dyadic  # exactly [#031]

      def initialize path_tail, cm
        @client = cm
        @path_tail = path_tail
      end

      def execute
        __init
        __init_two_paths
        x = @client.finish_via__ @__path_to_load, @_state_machine
        __maybe_autoloaderize_the_main_thing
        x
      end

      def __maybe_autoloaderize_the_main_thing  # note-1

        mod = @client.module
        nm = Name.via_slug @_piece
        camel = nm.as_camelcase_const
        if mod.const_defined? camel, false
          const = camel
        elsif mod.const_defined? nm.as_const, false
          const = nm.as_const
        else
          const = camel.upcase
          if ! mod.const_defined? const, false
            const = nil
          end
        end

        if const
          x = mod.const_get const, false
          if Should_probably_autoloaderize_[ x ]
            Here_[ x, @_node_path ]
          end
        end
        NIL
      end

      def __init_two_paths

        @_node_path_buffer = @_file_tree.node_path.dup

        begin
          if __found_filesystem_node_for_piece
            if __is_last_piece
              if __corresponds_to_file
                break __file
              else
                break self._TODO_EASY__directory
              end
            elsif __corresponds_to_directory
              __step
              redo
            else
              self._COVER_ME_bad_stowaway_path_file_too_early
            end
          else
            self._COVER_ME_bad_stowaway_path_no_filesystem_node
          end
        end while above

        @__path_to_load = remove_instance_variable :@_the_path_to_load
        @_node_path = remove_instance_variable :@_node_path_buffer

        NIL
      end

      def __file

        @_the_path_to_load = ::File.join(
          @_file_tree.node_path,
          @_state_machine.entry_group.filesystem_entry_string )
        NIL
      end

      def __step

        _sm = remove_instance_variable :@_state_machine
        _ft_ = @_file_tree.child_file_tree _sm
        @_file_tree = _ft_
        NIL
      end

      def __corresponds_to_file
        @_state_machine.entry_group.includes_what_is_probably_a_file
      end

      def __corresponds_to_directory
        @_state_machine.entry_group.includes_what_is_probably_a_directory
      end

      def __found_filesystem_node_for_piece

        @_piece = @_st.gets_one

        @_state_machine = @_file_tree.value_state_machine_via_head @_piece

        if @_state_machine
          @_node_path_buffer.concat ::File::SEPARATOR
          @_node_path_buffer.concat @_piece
          ACHIEVED_
        else
          UNABLE_
        end
      end

      def __is_last_piece
        yes = @_st.no_unparsed_exists
        if yes
          remove_instance_variable :@_st
        end
        yes
      end

      def __init
        @_st = Polymorphic_Stream.via_array @path_tail.split ::File::SEPARATOR
        @_file_tree = @client.module.entry_tree
        NIL
      end
    end
  end
end  # :#sm
# #tombstone: full rewrite
