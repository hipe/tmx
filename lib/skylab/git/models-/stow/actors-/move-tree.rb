module Skylab::Git

  class Models_::Stow

    class Actors_::Move_Tree

      def initialize tree_move, sym, fs, & oes_p

        @_do_prune_source_directories = true
        @filesystem = fs
        @on_event_selectively = oes_p
        @tree_move = tree_move
        if sym
          send :"#{ sym }="
        end
      end

      def do_not_prune=
        @_do_prune_source_directories = false
        # KEEP_PARSING_
      end

      def execute

        ok = __check_that_target_paths_are_unoccupied
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

        @on_event_selectively.call :error, :expression, :collision do | y |

          y << "destination file(s) exist:"

          a.each do | path |
            y << "  #{ path }"
          end
        end

        UNABLE_
      end

      def __init_dir_related

        tree = Home_.lib_.basic::Tree.mutable_node.new

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

          @on_event_selectively.call :info, :expression, :mkdir do | y |
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
          p = Callback_::Stream.via_nonsparse_array( @_dirs_fwd ).map_by do |s|
            ::File.join path, s
          end
          path
        end

        p = -> do
          p = p_
          _stows_path
        end

        Callback_.stream do
          p[]
        end
      end

      def __move_files

        @tree_move.each_path_pair do | src, dst |

          @filesystem.mv src, dst, & @on_event_selectively
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

        Callback_.stream do
          p[]
        end
      end
    end
  end
end
