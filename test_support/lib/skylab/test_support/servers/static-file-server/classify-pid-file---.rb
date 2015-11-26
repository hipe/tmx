module Skylab::TestSupport

  class Servers::Static_File_Server

    class Classify_PID_file___ < Callback_::Actor::Dyadic

      # given the PID path, resolve it into a "normal" PID path by adding
      # the default filename to the end of it as appropriate based on IFF
      # path exists and is a directory. this can fail IFF the path exists
      # and is neither file nor directory (NOT COVERED).

      # also: when it existed, validate & normalize ("parse") the content.

      def initialize path, fs, & p
        @filesystem = fs
        @_oes_p = p
        @_PID_path = path
      end

      def execute

        _ok = _recurse
        _ok && __via_inode
      end

      def _recurse

        fs = @filesystem
        begin
          stat = fs.stat @_PID_path
        rescue ::Errno::ENOENT
        end

        if stat
          case stat.ftype
          when fs.constants::DIRECTORY_FTYPE
            __when_PID_path_is_directory
          when fs.constants::FILE_FTYPE
            __when_PID_path_is_file
          else
            __when_strange_inode stat.ftype
          end
        else
          __when_PID_path_has_no_inode
        end
      end

      def __when_PID_path_is_directory  # LOOK

        @_PID_path = ::File.join @_PID_path, DEFAULT_BASENAME_
        _recurse
      end

      def __when_strange_inode x

        @_oes_p.call :error, :expression, :nope do | y |
          y << "no: #{ x }"
        end

        UNABLE_
      end

      def __when_PID_path_has_no_inode

        # if client passed a path for which no inode exists, then we
        # take the path to represent the would-be file and we effect
        # that the directory around it must already exist.

        _dirname = ::File.dirname @_PID_path

        _dir_exists = @filesystem.normalization( :Upstream_IO ).call(
          :path, _dirname,
          :must_be_ftype, :DIRECTORY_FTYPE,
          & @_oes_p )

        if _dir_exists
          @_file_did_exist = false
          ACHIEVED_
        else
          _dir_exists
        end
      end

      def __when_PID_path_is_file
        @_file_did_exist = true
        ACHIEVED_
      end

      def __via_inode

        if @_file_did_exist
          __when_file_did_exist
        else
          Did_Not_Exist.new @_PID_path
        end
      end

      def __when_file_did_exist

        path = @_PID_path
        s = @filesystem.open( path, ::File::RDONLY ).read
        md = /\A(?<digit>[0-9]+)\n?\z/.match s
        if md
          Did_Exist.new md[ :digit ].to_i, path
        else
          ___when_strange_content
        end
      end

      def ___when_strange_content

        path = @_PID_path
        @_oes_p.call :error, :expression, :nope do | y |
          y << "contents must look like digit - #{ pth path }"
        end
        UNABLE_
      end

      Did_Not_Exist = ::Struct.new :path do
        def did_exist
          false
        end
      end

      Did_Exist = ::Struct.new :PID, :path do
        def did_exist
          true
        end
      end
    end
  end
end
