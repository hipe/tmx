module Skylab::GitViz

  class Test_Lib_::Mock_Filesystem  # see [#013]

    class << self

      def enhance_client_class client

        client.include Client_Instance_Methods___
        NIL_
      end

      alias_method :__new_via_path, :new
      private :new
    end  # >>

    module Client_Instance_Methods___
    private

      def mock_filesystem
        @__mock_filesystem__ ||= Build_mock_filesystem_for___[ self ]
      end
    end

    Build_mock_filesystem_for___ = -> client do

      path = client.manifest_path_for_mock_FS  # #:+#hook-out

      cache = client.cache_hash_for_mock_FS  # #:+#hook-out

      o = cache[ path ]
      if ! o
        o = Models_::Mock_FS.__new_via_path path
        cache[ path ] = o
      end
      o
    end

    Models_ = ::Module.new
    Models_::Mock_FS = self
    class Models_::Mock_FS

      # (implemented as a tree) ("mentor" is [#sy-009])

      def initialize path

        fh = ::File.open path, ::File::RDONLY

        _st = Callback_.stream do

          line = fh.gets
          if line
            line.chomp!
            line.freeze
            Models_::Node.new line
          end
        end

        @_tree = Home_.lib_.basic::Tree.via :node_stream, _st

        fh.close
        freeze
      end

      # ~ read core serivces (per mentor)

      def build_directory_object path

        nd = _any_node_for path
        if nd
          if nd.is_branch
            Models_::Dir.new path
          else
            raise ::Errno::ENOTDIR.new( path, _here )
          end
        else
          raise ::Errno::ENOENT.new( path, _here )
        end
      end

      def _here
        'MOCKED_dir_initialize'
      end

      def directory? path

        nd = _any_node_for path
        if nd
          nd.is_branch
        else
          UNABLE_
        end
      end

      def exist? path

        _nd = _any_node_for path

        if _nd
          true
        else
          false
        end
      end

      def file? path

        nd = _any_node_for path
        if nd
          ! nd.is_branch
        else
          UNABLE_
        end
      end

      def stat path

        nd = _any_node_for path
        if nd
          Models_::Stat.new nd.is_branch ? :directory_ftype : :file_ftype
        else
          raise ::Errno::ENOENT, path
        end
      end

      # ~ "etc" core services per mentor

      def path_is_absolute path
        # let the real filesystem decide
        Home_.lib_.system.filesystem.path_is_absolute path
      end

      # ~ internal support

      def _any_node_for path

        _subbed = path.gsub ABNORMAL_SEPARATOR_RX__, EMPTY_S_
        _split = _subbed.split ::File::SEPARATOR
        _path_sym_a = _split.map( & :intern )

        @_tree.fetch_node _path_sym_a do end
      end
    end

    class Models_::Stat

      attr_reader :ftype

      def initialize ftype_sym
        send :"__init_as__#{ ftype_sym }__"
      end

      def __init_as__directory_ftype__
        @ftype = _const :DIRECTORY_FTYPE
        NIL_
      end

      def __init_as__file_ftype__
        @ftype = _const :FILE_FTYPE
        NIL_
      end

      def _const sym
        Home_.lib_.system.filesystem.constants.const_get sym, false
      end
    end

    class Models_::Dir
      attr_reader :to_path
      def initialize path
        @to_path = path
      end
    end

    class Models_::Node

      # comport to [ba] tree

      def initialize line  # #storypoint-90

        is_dir = FILE_SEPARATOR_BYTE_ == line.getbyte( -1 )

        path_i_a = line.gsub( ABNORMAL_SEPARATOR_RX__, EMPTY_S_ ).
          split( ::File::SEPARATOR, -1 ).map( & :intern )

        is_dir and path_i_a.push DOT_SYMBOL___

        @_tree_path = path_i_a.freeze
      end

      def to_tree_path
        @_tree_path
      end
    end

    ABNORMAL_SEPARATOR_RX__ = %r((?<=/)/+|/+\z)
    DOT_SYMBOL___ = :'.'
  end
end
# :+#tombstone: #storypoint-80
