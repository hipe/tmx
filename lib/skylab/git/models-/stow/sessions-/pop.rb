module Skylab::Git

  class Models_::Stow

    class Sessions_::Pop

      attr_accessor(
        :expressive_stow,
        :target_directory,
      )

      def initialize & x_p
        @on_event_selectively = x_p
      end

      def execute

        @_existed_path_a = nil
        @_filesystem = @expressive_stow.resources.filesystem

        __init_unit_of_work_array

        if @_existed_path_a
          __when_files_existed
        else
          __money
        end
      end

      def __init_unit_of_work_array

        st = @expressive_stow.to_item_stream
        uow_a = []

        begin

          item = st.gets
          item or break

          uw = Move_UoW___.new

          uw.source_path = item.get_path

          relpath = item.file_relpath
          path = ::File.expand_path relpath, @target_directory

          s = ::File.dirname relpath
          if DOT_ != s
            _normal, = Path_divmod_[ s ]  # remove leading "./"
            uw.dirs = _normal
          end

          uw.dest_path = path

          if @_filesystem.exist? path
            ( @_existed_path_a ||= [] ).push path
          end

          uow_a.push uw

          redo
        end while nil

        @_unit_of_work_a = uow_a
        NIL_
      end

      Move_UoW___ = ::Struct.new :source_path, :dest_path, :dirs

      def __when_files_existed

        @on_event_selectively.call :error, :expression, :collision do | y |

          y << "destination file(s) exist:"

          @_existed_path_a.each do | path |
            y << "  #{ path }"
          end
        end

        UNABLE_
      end

      def __money

        st = Callback_::Stream.via_nonsparse_array @_unit_of_work_a

        begin
          uw = st.gets
          uw or break

          dir = ::File.dirname uw.dest_path

          if ! @_filesystem.directory? dir
            _mkdir_p dir
          end

          @_filesystem.mv uw.source_path, uw.dest_path, & @on_event_selectively

          redo
        end while nil

        __prune_directories
      end

      def _mkdir_p dir

        stack = [ dir ]

        begin
          dir_ = ::File.dirname dir
          if dir == dir_
            break
          end
          if @_filesystem.directory? dir_
            break
          end
          stack.push dir_
          dir = dir_
          redo
        end while nil

        begin
          dir = stack.pop

          @on_event_selectively.call :info, :expression, :mkdir do | y |
            y << "mkdir #{ dir }"
          end

          @_filesystem.mkdir dir

          if stack.length.zero?
            break
          end
          redo
        end while nil
      end

      def __prune_directories

        # depth-first in reverse so we remove child dirs
        # before the parent dir that contains them

        tree = Home_.lib_.basic::Tree.mutable_node.new

        @_unit_of_work_a.each do | uw |
          s = uw.dirs
          s or next
          tree.touch_node s
        end

        rel_a = tree.to_stream_of( :paths ).to_a

        path = @expressive_stow.path

        begin
          rel = rel_a.pop
          rel or break
          @_filesystem.rmdir ::File.join( path, rel )
          redo
        end while nli

        ACHIEVED_
      end

      ACHIEVED_ = true
      DOT_ = '.'
    end
  end
end
