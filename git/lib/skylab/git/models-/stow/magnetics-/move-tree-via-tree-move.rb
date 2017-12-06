module Skylab::Git

  class Models_::Stow

    class Magnetics_::MoveTree_via_TreeMove < Common_::MagneticBySimpleModel  # 1x

      def initialize
        @_do_prune_source_directories = true
        super
      end

      def do_not_prune
        @_do_prune_source_directories = false ; nil
      end

      attr_writer(
        :filesystem,
        :listener,
        :tree_move,
      )

      def execute
        ok = true
        ok &&= __check_that_target_paths_are_unoccupied
        ok && __init_dir_related
        ok &&= __touch_target_directories
        ok &&= __move_files
        ok && __maybe_prune_source_directories
      end

      def __check_that_target_paths_are_unoccupied

        a = nil

        @tree_move.each_destination_path do | path |
          if @filesystem.exist? path
            ( a ||= [] ).push path
          end
        end

        if a
          __when_files_existed a
        else
          ACHIEVED_
        end
      end

      def __when_files_existed a

        @listener.call :error, :expression, :collision do | y |

          y << "destination file(s) exist:"

          a.each do | path |
            y << "  #{ path }"
          end
        end

        UNABLE_
      end

      def __init_dir_related

        tree = Home_.lib_.basic::Tree::Mutable.new

        @tree_move.a.each do | relpath |

          dir = ::File.dirname relpath
          DOT_ == dir and next
          tree.touch_node dir
        end

        @_dirs_fwd = tree.to_stream_of( :paths ).to_a
        NIL_
      end

      def __touch_target_directories

        # (implicitly this also catches cases of files existing in the
        #  places where directories will have to exist or be created)

        st = __to_forward_directory_stream

        begin
          dir = st.gets
          dir or break
          _yes = @filesystem.directory? dir
          _yes and redo

          @listener.call :info, :expression, :mkdir do | y |
            y << "mkdir #{ dir }"
          end

          @filesystem.mkdir dir
          redo
        end while nil

        ACHIEVED_
      end

      def __to_forward_directory_stream

        path = @tree_move.destination_path

        _stows_path = ::File.dirname path

        p = nil

        p_ = -> do
          p = Stream_[ @_dirs_fwd ].map_by do |s|
            ::File.join path, s
          end
          path
        end

        p = -> do
          p = p_
          _stows_path
        end

        Common_.stream do
          p[]
        end
      end

      def __move_files

        @tree_move.each_path_pair do | src, dst |

          @filesystem.mv src, dst, & @listener
        end
        ACHIEVED_
      end

      def __maybe_prune_source_directories

        if @_do_prune_source_directories
          __prune_source_directories
        else
          ACHIEVED_
        end
      end

      def __prune_source_directories

        st = __to_source_directory_stream

        begin
          dir = st.gets
          dir or break
          @filesystem.rmdir dir
          redo
        end while nil
        ACHIEVED_
      end

      def __to_source_directory_stream

        path = @tree_move.source_path

        a = @_dirs_fwd
        d = a.length
        p = -> do
          if d.zero?
            p = EMPTY_P_
            path
          else
            d -= 1
            ::File.join path, a.fetch( d )
          end
        end

        Common_.stream do
          p[]
        end
      end

      # ==
      # ==
    end
  end
end
