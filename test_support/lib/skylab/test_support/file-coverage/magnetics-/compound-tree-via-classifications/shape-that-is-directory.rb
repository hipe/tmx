module Skylab::TestSupport

  module FileCoverage

    class Magnetics_::CompoundTree_via_Classifications

      module Shape_that_Is_Directory

        def execute
          Path_looks_absolute_[ @path ] || Home_._SANITY
          init
          ok = __resolve_the_big_tree
          ok && __break_the_big_tree_up_into_big_asset_tree_and_big_test_tree
          ok && __init_pre_pruned_trees_by_maybe_pruning_the_long_stem
          ok && __init_normal_keyed_asset_tree_via_pre_pruned_asset_tree
          ok && __init_normal_keyed_test_tree_pre_pruned_test_tree
          ok && __maybe_prune_the_other_tree
          ok && __via_normal_keyed_trees_produce_the_combined_tree
        end

        def __resolve_the_big_tree

          # the "big tree" is derived from the paths of the files. what files?
          # the files from the "business hub dir" ("BHD") that match the "big
          # tree filename patterns". what patterns? see [#013]:#note-1.

          _big_tree_filename_patterns = @name_conventions.big_tree_filename_patterns__

          command = Home_.lib_.system.find(
            :path, @business_hub_dir_,
            :filenames, _big_tree_filename_patterns,
              :freeform_query_infix_words, TYPE_FILE___,
            :when_command, IDENTITY_,
          )

          _st = command.to_path_stream

          r = @asset_local_range_
          _st_ = _st.map_by do |path|
            path[ r ]
          end

          tree = Tree_lib_[].via :paths, _st_

          # (it's much easier to debug if we give this case special handling
          # later on, even though the whole pipeline should be able to handle
          # the zero-length case (trees and so on).)

          if tree.length.zero?
            # #todo - covered only visually - only worked at time of writing
            __when_none_found command
            UNABLE_
          else
            @__big_tree = tree ; ACHIEVED_
          end
        end

        TYPE_FILE___ = %w( -type file )

        def __when_none_found command
          @on_event_selectively_.call :error, :expression, :no_files_found do |y|
            _s = command.express_into_under "", self
            y << "no files found by #{ _s }"
          end
          NIL
        end

        def __break_the_big_tree_up_into_big_asset_tree_and_big_test_tree

          # the resulting test tree contains every file with the pattern
          # of interest, including possibly non-test files.

          big_tree = remove_instance_variable :@__big_tree

          @_test_dir_localized = @test_dir[ @asset_local_range_ ]

          filename = Here_::Models_::Filename.new @_test_dir_localized

          _path_to_parent_dir = filename.directory_entry_string_array

          _will_lose_child = big_tree.fetch_node _path_to_parent_dir

          _test_node = _will_lose_child.remove filename.file_entry  # #entry-model

          t = Models_::Trees.new
          t.asset = big_tree
          t.test = _test_node
          @_full = t
          NIL
        end

        def __init_pre_pruned_trees_by_maybe_pruning_the_long_stem

          # the BHD is simply the directory surrounding the test directory.
          # if the argument path *is* either (doesn't matter which) of these,
          #   if the BHD looks like a gem, do special handling there
          #   otherwise life is easy: no pruning to do.
          # otherwise (and the argument path was not touching the BHD, i.e
          # it did not point to the "root" of the "project"), then what we
          # do is not well-documentd, but meant to show only the node (pair)
          # of interest.

          full = remove_instance_variable :@_full
          tdl = remove_instance_variable :@_test_dir_localized

          if @business_hub_dir_ == @path || @test_dir == @path

            @_prune_the_other_tree_in_this_order = nil

            @_pre_pruned = if full.asset.has_name LIB_ENTRY_

              Magnetics_::TwoTrees_via_BigTreePattern::Gem[ full, @name_conventions ]
            else
              full
            end
          else

            o = Magnetics_::TwoTrees_via_BigTreePattern::SubPath.call(
              @path[ @asset_local_range_ ], tdl, full )

            @_pre_pruned = o.pre_pruned
            @_prune_the_other_tree_in_this_order = o.order
            @_real_prune_path_array_for = o.paths
          end
          NIL
        end

        def __init_normal_keyed_asset_tree_via_pre_pruned_asset_tree

          tr = @_pre_pruned.asset
          @_pre_pruned.asset = nil

          _tr_ = _normal_keyed_tree_via_pre_pruned_tree tr,
            :normal_string_for_asset_dir_entry,
            :normal_string_for_asset_file_entry,
            :receive_asset_dir_entry_string_,
            :receive_asset_file_entry_string_

          trees = Models_::Trees.new
          trees.asset = _tr_
          @_normal_keyed = trees
          NIL
        end

        def __init_normal_keyed_test_tree_pre_pruned_test_tree

          _pp = remove_instance_variable :@_pre_pruned

          _tr_ = _normal_keyed_tree_via_pre_pruned_tree _pp.test,
            :normal_string_for_test_dir_entry,
            :normal_string_for_test_file_entry,
            :receive_test_dir_entry_string_,
            :receive_test_file_entry_string_

          @_normal_keyed.test = _tr_
          NIL
        end

        def _normal_keyed_tree_via_pre_pruned_tree tree, dir_m, file_m, recv_dir_m, recv_file_m

          # given a tree that looks like a filesystem tree, result in a new
          # tree that has a similar structure but all the "keys" of each of
          # the branch nodes have been normalized ("dumbed down") using
          # whatever policies of the given name conventions.

          dir_key_for = @name_conventions.method dir_m
          file_key_for = @name_conventions.method file_m

          depth = 0
          output_node = Tree_lib_[].mutable_node.new
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

              dir_key_for[ input_node.slug ]
            else
              file_key_for[ input_node.slug ]
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
              Here_::Models_::Node.new
            end

            _m = if input_node.has_children
              recv_dir_m
            else
              recv_file_m
            end

            output_node.node_payload.send _m, input_node.slug

            redo
          end while nil

          tree_
        end

        def __maybe_prune_the_other_tree

          a = remove_instance_variable :@_prune_the_other_tree_in_this_order
          if a
            __prune_the_other_tree( * a )
          end
          NIL
        end

        def __prune_the_other_tree left, right

          m = THESE___.fetch left

          _normal_path = @_real_prune_path_array_for[ left ].map do | s |
            @name_conventions.send m, s
          end

          x = @_normal_keyed[ right ].fetch_node _normal_path do end
          if x
            @_normal_keyed[ right ] = x
          else
            @_normal_keyed[ right ] = @_normal_keyed[ right ].class.new
              # make a new mutable empty box. it will be the mutatee or destructee
          end
          NIL
        end

        THESE___ = {
          asset: :normal_string_for_asset_dir_entry,
          test: :normal_string_for_test_dir_entry,
        }

        def __via_normal_keyed_trees_produce_the_combined_tree

          # now that you have the two trees with normal keys, you can zip
          # them together and see what happens

          o = remove_instance_variable :@_normal_keyed
          test_tree = o.test
          test_tree.merge_destructively o.asset
          test_tree
        end
      end
    end
  end
end
