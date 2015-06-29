module Skylab::Plugin

  Bundle::Fancy_lookup = -> do  # exegesis at [#024]

    parse_lib = -> do
      Home_.lib_.parse
    end

    skip_rx = /_spec\z/

    build_parse_function_via_entry_tree = -> entry_tree do

      parse_lib[].function( :item_from_matrix ).new_with(

        :item_stream_proc, -> do

          st = entry_tree.to_stream

          Callback_.stream do

            begin
              entry = st.gets
              entry or break
              if skip_rx =~ entry.name.as_slug
                redo
              end
              break
            end while nil

            if entry

              Callback_::Pair.new entry, ( entry.name.as_slug.split DASH_ )
            end
          end
        end

      ) do | * _i_a, & x_p |

        raise x_p[].to_exception
      end
    end

    build_to_const = -> received_s_a, in_st do

      -> before_index do
        current_index = in_st.current_index
        d = before_index
        d_ = current_index - 1
        s_a = ::Array.new current_index - before_index
        begin
          s = received_s_a.fetch d
          s_a[ d - before_index ] = "#{ s[ 0 ].upcase }#{ s[ 1 .. -1 ] }"
          d_ == d and break
          d += 1
          redo
        end while nil
        s_a.join( UNDERSCORE_ ).intern
      end
    end

    -> sym, mod do

      s = sym.id2name

      in_st = parse_lib[].input_stream.via_array s.downcase.split( UNDERSCORE_ )

      received_s_a = s.split UNDERSCORE_

      to_const = build_to_const[ received_s_a, in_st ]

      et = mod.entry_tree

      begin

        before_index = in_st.current_index

        # advance the scanner to the boundary between one node and the next:

        pair = build_parse_function_via_entry_tree[ et ].
          output_node_via_input_stream in_st

        # then we can determine the const name from the above:

        et_ = pair.value_x

        const = to_const[ before_index ]

        if in_st.unparsed_exists  # note-05 - we can infer it's a branch node

          if mod.const_defined? const, false

            mod_ = mod.const_get const, false

          else

            mod_ = ::Module.new

            mod.const_set const, mod_

            mod.autoloaderize_with_normpath_value et_, mod_

          end

          et = et_
          mod = mod_

          redo
        end

        break
      end while nil

      # when we get here there is nothing more to parse in the name, so
      # we infer with certainty that `const` under `mod` is target "x".
      # this is where there are many #assumptions-made.

      _require_me = et_.get_require_file_path

      require _require_me  # not load, because a child bundle
        # node may have already loaded this node as parent

      mod.const_get const, false
    end
  end.call
end
