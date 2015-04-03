module Skylab::SubTree

  class Models_::File_Coverage

    class Actors_::Build_compound_tree

      module For_directory___

        def execute

          ::File::SEPARATOR == @path[ 0, 1 ] or raise ::ArgumentError  # sanity

          init

          ok = __resolve_the_big_tree
          ok &&= __break_the_big_tree_up_into_big_asset_tree_and_big_test_tree
          ok &&= __maybe_prune_one_big_tree
          ok &&= __prepare_the_asset_tree
          ok &&= __prepare_the_test_tree
          ok &&= __maybe_prune_the_other_tree
          ok && __via_prepared_trees_produce_the_combined_tree
        end

        def __resolve_the_big_tree

          _st = SubTree_.lib_.system.filesystem.find( :path, @business_hub_dir_,
              :filename, "*#{ Autoloader_::EXTNAME }",  # here we :+[#008] assume all relevant files have one same extension
              :freeform_query_infix_words, TYPE_FILE___,
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
        TYPE_FILE___ = %w( -type file )

        def __break_the_big_tree_up_into_big_asset_tree_and_big_test_tree

          @test_dir_localized = @test_dir[ @asset_local_range_ ]

          td_fn = File_Coverage_::Models_::Filename.new @test_dir_localized

          _will_lose_child = @big_tree.fetch_node td_fn.to_dir_entry_stream.map( & :string )

          @big_trees = Trees__.new
          @big_trees[ :asset ] = @big_tree
          @big_tree = nil

          @big_trees[ :test ] = _will_lose_child.remove td_fn.file_entry.to_s

          ACHIEVED_
        end

        def __maybe_prune_one_big_tree

          @pre_pruned_trees = Trees__.new

          if @business_hub_dir_ == @path || @test_dir == @path

            @prune_the_other_tree = nil

            @pre_pruned_trees[ :asset ] = @big_trees[ :asset ]
            @pre_pruned_trees[ :test ] = @big_trees[ :test ]
            @big_trees[ :asset ] = @big_trees[ :test ] = nil

            ACHIEVED_

          else
            __prune_one_big_tree
          end
        end

        def __prune_one_big_tree  # assume path is not test dir

          sub_path = @path[ @asset_local_range_ ]
          test_head = "#{ @test_dir_localized }#{ ::File::SEPARATOR }"

          if test_head == sub_path[ 0, test_head.length ]

            _path = sub_path[ test_head.length .. -1 ]

            _prune_this_big_tree _path, :test, :asset

          else

            # :+[#014] - test dir is *within* asset dir, hence the asymmetry

            _prune_this_big_tree sub_path, :asset, :test
          end
        end

        def _prune_this_big_tree real_path, left, right

          path_a = real_path.split ::File::SEPARATOR

          @real_prune_path_a_for = Trees__.new

          @real_prune_path_a_for[ left ] = path_a

          _x = @big_trees[ left ].fetch_node path_a do end

          @pre_pruned_trees[ left ] = _x
          @big_trees[ left ] = nil

          @pre_pruned_trees[ right ] = @big_trees[ right ]
          @big_trees[ right ] = nil

          @prune_the_other_tree = [ left, right ]

          ACHIEVED_
        end

        def __normalize_test_subdir_path path_s

          path_s.split( ::File::SEPARATOR ).map do | s |

            @nc.normal_string_for_test_dir_entry s
          end
        end

        def __prepare_the_asset_tree

          @prepared_trees = Trees__.new

          tr = _build_prepared_tree @pre_pruned_trees[ :asset ],
            :normal_string_for_asset_dir_entry,
            :normal_string_for_asset_file_entry,
            :receive_asset_dir_entry_string_,
            :receive_asset_file_entry_string_

          tr and begin
            @pre_pruned_trees[ :asset ] = nil
            @prepared_trees[ :asset ] = tr
            ACHIEVED_
          end
        end

        Trees__ = ::Struct.new :asset, :test

        def __prepare_the_test_tree

          tr = _build_prepared_tree @pre_pruned_trees[ :test ],
            :normal_string_for_test_dir_entry,
            :normal_string_for_test_file_entry,
            :receive_test_dir_entry_string_,
            :receive_test_file_entry_string_

          tr and begin
            @pre_pruned_trees[ :test ] = nil
            @prepared_trees[ :test ] = tr
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

        def __maybe_prune_the_other_tree

          a = @prune_the_other_tree
          if a
            __prune_the_other_tree( * a )
          else
            ACHIEVED_
          end
        end

        def __prune_the_other_tree left, right

          m = :"normal_string_for_#{ left }_dir_entry"  # ick/meh

          _normal_path = @real_prune_path_a_for[ left ].map do | s |
            @nc.send m, s
          end

          x = @prepared_trees[ right ].fetch_node _normal_path do end
          if x
            @prepared_trees[ right ] = x
          else
            @prepared_trees[ right ] = @prepared_trees[ right ].class.new
              # make a new mutable empty box. it will be the mutatee or destructee
          end

          ACHIEVED_
        end

        def __via_prepared_trees_produce_the_combined_tree

          @prepared_trees[ :test ].merge_destructively @prepared_trees[ :asset ]
          @prepared_trees[ :test ]
        end
      end
    end
  end
end
