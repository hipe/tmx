module Skylab::SubTree

  class Models_::File_Coverage

    class Actors_::Build_compound_tree

      module For_directory___

        def execute
          init
          send :"__from__#{ @cx.testiness }__"
        end

        def __from__test__

          ok = __resolve_the_big_tree
          ok &&= __break_the_big_tree_up_into_big_asset_tree_and_big_test_tree
          ok &&= __maybe_prune_the_big_trees
          ok &&= __prepare_the_asset_tree
          ok &&= __prepare_the_test_tree
          ok && __via_prepared_trees_produce_the_combined_tree
        end

        def __resolve_the_big_tree

          _st = SubTree_.lib_.system.filesystem.find( :path, @business_hub_dir_,
              :filename, "*#{ Autoloader_::EXTNAME }",  # here we :+[#008] assume all relevant files have one same extension
              :freeform_query_infix_words, %w( -type file ),
              :as_normal_value, -> cmd do
                cmd.to_path_stream
              end )

          r = @asset_local_range_
          _st = _st.map_by do | path |

            path[ r ]
          end

          @big_tree = SubTree_::lib_.tree.via :paths, _st
          ACHIEVED_
        end

        def __break_the_big_tree_up_into_big_asset_tree_and_big_test_tree

          td_fn = File_Coverage_::Models_::Filename.new @test_dir[ @asset_local_range_ ]

          _will_lose_child = @big_tree.fetch_node td_fn.to_dir_entry_stream.map( & :string )

          @big_asset_tree = @big_tree
          @big_tree = nil
          @big_test_tree = _will_lose_child.remove td_fn.file_entry.to_s

          ACHIEVED_
        end

        def __maybe_prune_the_big_trees

          if @business_hub_dir_ == @path || @test_dir == @path

            @pruned_asset_tree = @big_asset_tree
            @pruned_test_tree = @big_test_tree
            @big_asset_tree = @big_test_tree = nil

            ACHIEVED_

          else

            __prune_the_big_trees
          end
        end

        def __prune_the_big_trees

          _sub_path = @path[ @asset_local_range_ ]

          self._FUN
        end

        def __prepare_the_asset_tree

          tr = _build_prepared_tree @pruned_asset_tree,
            :normal_string_for_asset_dir_entry,
            :normal_string_for_asset_file_entry,
            :receive_asset_dir_entry_string_,
            :receive_asset_file_entry_string_

          tr and begin
            @pruned_asset_tree = nil
            @prepared_asset_tree = tr
            ACHIEVED_
          end
        end

        def __prepare_the_test_tree

          tr = _build_prepared_tree @pruned_test_tree,
            :normal_string_for_test_dir_entry,
            :normal_string_for_test_file_entry,
            :receive_test_dir_entry_string_,
            :receive_test_file_entry_string_

          tr and begin
            @pruned_test_tree = nil
            @prepared_test_tree = tr
            ACHIEVED_
          end
        end

        def _build_prepared_tree tree, dir_key, file_key, recv_dir, recv_file

          # build a tree based on the argument tree but reduced to only
          # normalized file (or directory) entr names per name conventions.
          # while so doing, memoize the input data into the output_node payloads.

          dir_key = @nc.method dir_key
          file_key = @nc.method file_key

          depth = 0
          output_node = SubTree_.lib_.tree.mutable_node.new
          parents = []
          st = tree.to_classified_stream
          tree_ = output_node

          st.gets  # root node is never for us, corresponds to above tree

          begin
            cx = st.gets
            cx or break
            depth_ = cx.depth
            input_node = cx.node


            normal_s = if input_node.has_children

              dir_key[ input_node.slug ]
            else

              file_key[ input_node.slug ]
            end

            normal_s or redo  # some files are not relevant to the concern


            _my_parent = case depth <=> depth_

            when 0  # the current input node is at the same level as previous

              parents.fetch( depth - 1 )

            when -1  # the current input node is deeper than previous

              depth = depth_
              parents.push output_node
              output_node

            when 1  # the current input node is shallower than previous

              depth = depth_
              parents[ depth .. -1 ] = EMPTY_A_
              parents.fetch( depth - 1 )
            end


            output_node = _my_parent.touch_node normal_s do
              File_Coverage_::Models_::Node.new
            end

            _method = if input_node.has_children
              recv_dir
            else
              recv_file
            end

            output_node.node_payload.send _method, input_node.slug

            redo
          end while nil

          tree_
        end

        def __via_prepared_trees_produce_the_combined_tree

          @prepared_test_tree.merge_destructively @prepared_asset_tree
          @prepared_test_tree
        end
      end
    end
  end
end
