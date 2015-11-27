module Skylab::Plugin

  class Bundle::Fancy_lookup  # exegesis at [#024], which has..

    # incomplete pseudocde for a [#.A] general & [#.B] particular algorithm

    Callback_::Actor.methodic( self, :properties,

      :stemname_filter,
    )

    def initialize & edit_p

      @stemname_filter = nil

      instance_exec( & edit_p )
    end

    def against sym, mod

      otr = dup
      otr.__receive_sym_and_mod sym, mod
      otr.__execute
    end

    def __receive_sym_and_mod sym, mod

      s = sym.id2name

      _ = s.downcase.split UNDERSCORE_, -1  # include trailing underscores..

      @_in_st = _parse_lib.input_stream.via_array _

      s_a = s.split UNDERSCORE_, -1

      @_received_s_a = s_a

      d = 0  # (handle trailing underscores in an OCD way)
      if s_a.last.length.zero?
        s_a = s_a.dup
        begin
          s_a.pop
          d += 1
        end while s_a.last.length.zero?
      end

      const_s_a = s_a.map do | s_ |
        "#{ s_[ 0 ].upcase }#{ s_[ 1..-1 ] }"
      end

      d.times do
        const_s_a.push EMPTY_S_
      end

      @_const_s_a = const_s_a

      @_module = mod
      NIL_
    end

    def __execute

      begin

        if __module_has_item_per_remainder
          x = @_result
          break
        end

        @_entry_tree = @_module.entry_tree

        if ! @_entry_tree.has_directory

          # ~ since it's not a directory, assume we have to load one & done

          x = self._COVER_ME_finish_because_terminal_file_is_reached
          break
        end

        _done = __step
        if _done
          x = @_result
          break
        end
        redo
      end while nil

      x
    end

    def __module_has_item_per_remainder

      const = @_const_s_a[ @_in_st.current_index .. -1 ].
        join( UNDERSCORE_ ).intern

      if @_module.const_defined? const, false
        @_result = @_module.const_get const, false
        ACHIEVED_
      else
        UNABLE_
      end
    end

    def __step

      # advance scanner to boundary between one node and the next (money):

      @_d = @_in_st.current_index

      _ = __build_parse_function_via_entry_tree
      pair = _.output_node_via_input_stream @_in_st

      @_this_entry_tree = pair.value_x

      @_const = __const_per_step

      is_final = @_in_st.no_unparsed_exists  # #note-05 - we can infer ..

      if @_module.const_defined? @_const, false

        @_module = @_module.const_get @_const

      elsif is_final

        @_result = __load_final_file
        ACHIEVED_
      else

        @_module = __build_and_load_module
      end

      if is_final
        ACHIEVED_
      else
        @_entry_tree = remove_instance_variable :@_this_entry_tree
        NIL_  # keep going
      end
    end

    def __build_and_load_module

      et = @_this_entry_tree

      o = ::Module.new
      @_module.const_set @_const, o
      @_module.autoloaderize_with_normpath_value et, o

      # we require and not load the file because a child node may have
      # already loaded this node as a parent before this actor's invocation

      if et.can_produce_load_file_path
        ::Kernel.require et.get_require_file_path
      else
        # nothing to load. there is no such file.
      end

      o
    end

    def __load_final_file

      et = @_this_entry_tree
      ::Kernel.load et.get_load_file_path

      x = @_module.const_get @_const, false
      if x.respond_to? :module_exec
        @_module.autoloaderize_with_normpath_value et, x
      end
      x
    end

    def __const_per_step

      current_index = @_in_st.current_index
      d = @_d
      d_ = current_index - 1
      s_a = ::Array.new current_index - @_d

      begin
        s = @_received_s_a.fetch d
        s_a[ d - @_d ] = "#{ s[ 0 ].upcase }#{ s[ 1 .. -1 ] }"
        d_ == d and break
        d += 1
        redo
      end while nil

      s_a.join( UNDERSCORE_ ).intern
    end

    def __build_parse_function_via_entry_tree

      et = @_entry_tree
      rx = @stemname_filter

      _parse_lib.function( :item_from_matrix ).new_with(

        :item_stream_proc, -> do

          st = et.to_stream

          Callback_.stream do

            begin
              entry = st.gets
              entry or break
              if rx =~ entry.name.as_slug
                redo
              end
              break
            end while nil

            if entry

              Callback_::Pair.via_value_and_name(
                entry,
                entry.name.as_slug.split( DASH_ ) )
            end
          end
        end

      ) do | * _i_a, & ev_p |

        raise ev_p[].to_exception
      end
    end

    def _parse_lib
      Home_.lib_.parse
    end
  end
end
# :+#tombstone: was originally implemented in a functional style as an excercise
