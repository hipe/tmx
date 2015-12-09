module Skylab::SubTree

  class Models_::File_Coverage

    class Actors_::Build_compound_tree

      module For_single_file___

        def execute
          init
          send :"__from__#{ @cx.testiness }__"
        end

        def __from__asset__

          fn = _filename_via_path @path[ @asset_local_range_ ]

          a = []
          fn.to_dir_entry_stream.each do | entry |
            a.push @nc.normal_string_for_asset_dir_entry entry
          end

          compare = @nc.normal_string_for_asset_file_entry fn.file_entry

          test_dir = ::File.join @test_dir, * a

          test_fn = @fs.entry_stream( test_dir ).flush_until_map_detect do | s |

            ent = File_Coverage_::Models_::Entry[ s ]

            if compare == @nc.normal_string_for_test_file_entry( ent )

              _path = if a.length.zero?
                ent.to_s
              else
                ::File.join( test_dir[ @test_local_range ], ent.to_s )
              end

              _filename_via_path _path
            end
          end

          _touch_asset_filename fn

          if test_fn

            _touch_test_filename test_fn

          end

          @tree
        end

        def __from__test__

          @test_fn = _filename_via_path @path[ @test_local_range ]

          _touch_test_filename @test_fn

          __via_test_filename_to_asset_path_stream.each do | path |

            _touch_asset_filename _filename_via_path path[ @asset_local_range_ ]
          end

          @tree
        end

        def _filename_via_path path

          File_Coverage_::Models_::Filename.new path
        end

        def init

          super

          @test_local_range = produce_local_range_ @test_dir

          @tree = Home_.lib_.tree.mutable_node.new

          NIL_
        end

        def _touch_test_filename fn

          _touch_filename fn,

            :normal_string_for_dir_entry, -> entry do

              @nc.normal_string_for_test_dir_entry entry
            end,

            :each_dir_entry, -> npl, entry do

              npl.receive_test_dir_entry_string_ entry.to_s
            end,

            :normal_string_for_file_entry, -> entry do

              @nc.normal_string_for_test_file_entry entry
            end,

            :each_file_entry, -> npl, entry do
              npl.receive_test_file_entry_string_ entry.to_s
            end

          NIL_
        end

        def _touch_asset_filename fn

          _touch_filename fn,

            :normal_string_for_dir_entry, -> entry do

              @nc.normal_string_for_asset_dir_entry entry
            end,

            :each_dir_entry, -> npl, entry do

              npl.receive_asset_dir_entry_string_ entry.to_s
            end,

            :normal_string_for_file_entry, -> entry do

              @nc.normal_string_for_asset_file_entry entry
            end,

            :each_file_entry, -> npl, entry do

              npl.receive_asset_file_entry_string_ entry.to_s
            end

          NIL_
        end

        def _touch_filename fn, * x_a

          o = Touch_Filename___.new
          x_a.each_slice 2 do | sym, x |
            o[ sym ] = x
          end

          dir_key = o.normal_string_for_dir_entry
          _file_key = o.normal_string_for_file_entry

          tree_node = @tree

          fn.to_dir_entry_stream.each do | entry |

            tree_node = tree_node.touch_node dir_key[ entry ] do
              File_Coverage_::Models_::Node.new
            end

            o.each_dir_entry[ tree_node.node_payload, entry  ]
          end

          fe = fn.file_entry

          _leaf = tree_node.touch_node _file_key[ fe ] do
            File_Coverage_::Models_::Node.new
          end

          o.each_file_entry[ _leaf.node_payload, fe ]

          NIL_
        end

        Touch_Filename___ = ::Struct.new :each_dir_entry, :each_file_entry,

          :normal_string_for_dir_entry, :normal_string_for_file_entry

        def __via_test_filename_to_asset_path_stream

          file_base = @nc.normal_string_for_test_file_entry @test_fn.file_entry

          file_base or raise __say @test_fn.file_entry

          __via_test_filename_to_final_directory_stream.expand_by do | dir |

            __to_N_tries_file_stream( dir, file_base ).reduce_by do | path |

              @fs.file? path
            end
          end
        end

        def __say entry
          "does not look like test file - #{ entry.to_s.inspect }"
        end

        def __via_test_filename_to_final_directory_stream

          st = Callback_::Stream.via_item ::File.dirname @test_dir

          @test_fn.to_dir_entry_stream.each do | entry |

            st = st.expand_by do | full_path |

              __to_N_tries_dir_stream( full_path, entry.to_s ).reduce_by do | full_path_ |

                @fs.directory? full_path_

              end
            end
          end

          st
        end

        def __to_N_tries_dir_stream dir, entry_s

          Callback_::Stream.via_times ETC__.length do | d |

            ::File.join dir, "#{ entry_s }#{ ETC__.fetch d }"
          end
        end

        def __to_N_tries_file_stream dir, entry_s

          Callback_::Stream.via_times ETC__.length do | d |

            ::File.join dir, "#{ entry_s }#{ ETC__.fetch d }#{ Autoloader_::EXTNAME }"
          end
        end

        ETC__ = [ nil, DASH_, "#{ DASH_ }#{ DASH_ }" ]

        N__ = 1  # number of trailing sub-parts to disregard in test file entries
      end
    end
  end
end
