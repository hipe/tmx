module Skylab::System

  class Services___::Filesystem  # see [#009]

    class << self  # experimental static lib interface

      def event sym
        FS_::Events_.const_get sym, false
      end
    end  # >>

    def initialize _svx
    end

    # ~ actor exposures

    def flock_first_available_path * x_a, & x_p

      FS_::Actors_::Flock_first_available_path.for_mutable_args_ x_a, & x_p
    end

    def hack_guess_module_tree * x_a, & x_p

      FS_::Actors_::Hack_guess_module_tree.for_mutable_args_ x_a, & x_p
    end

    # ~ bridge exposures

    def cache
      @___cache_bridge ||= FS_::Bridges_::Cache.new self
    end

    def file_utils_controller & x_p

      FS_::Bridges_::File_Utils_Controller.for_any_proc_( & x_p )
    end

    def find * x_a, & x_p

      FS_::Bridges_::Find.for_mutable_args_ x_a, & x_p
    end

    def grep * x_a, & x_p

      FS_::Bridges_::Grep.for_mutable_args_ x_a, & x_p
    end

    def patch * x_a, & x_p

      @__cache ||= {}  # we haven't needed to memoize any other daemon yet

      _service_controller = @__cache.fetch :patch do
        @__cache[ :patch ] = FS_::Bridges_::Patch.new :_no_svx
      end

      _service_controller.call_via_arglist x_a, & x_p
    end

    def path_tools
      FS_::Bridges_::Path_Tools
    end

    # ~ model exposures

    ## ~~ dir as collection

    def directory_as_collection & build

      FS_::Models::Directory::As::Collection.new do | o |
        o.filesystem = self  # as a default
        build[ o ]
      end
    end

    ## ~~ tmpdir

    def tmpdir_path
      @__tmpdir_path ||= Home_.lib_.tmpdir
    end

    def tmpdir * x_a, & x_p

      FS_::Models_::Tmpdir.for_mutable_args_ x_a, & x_p
    end

    # ~ normalization exposures

    def for_mutable_args_ x_a

      if x_a.length.zero?
        self
      else  # see [#.C]
        _cls = Normalizations_.const_get( * x_a, false )
        _cls.begin_ self
      end
    end

    # ~ session exposures

    def tmpfile_sessioner
      FS_::Sessions_::Tmpfile_Sessioner
    end

    def walk * x_a, & oes_p

      FS_::Sessions_::Walk.for_mutable_args_ x_a, & oes_p
    end

    # ~ hook-outs / internal / low-level

    def constants
      FS_
    end

    def members
      self.class.instance_methods false  # neat
    end

    def modality_const
      :Filesystem
    end

    # ->

      # ~ peripheral but nearby

      def line_stream_via_path path, num_bytes=nil

        _io = open path, ::File::RDONLY  # *NOT* the kernel method, ours

        Home_::IO.line_stream _io, num_bytes
      end

      # ~ read :+#core-services

      def build_directory_object path
        ::Dir.new path
      end

      def directory? s
        ::File.directory? s
      end

      def entry_stream abs_path

        a = ::Dir.entries abs_path
        d = 0
        len = a.length

        if DOT_ == a[ d ]

          d += 1

          if DOT_DOT__ == a[ d ]
            d += 1
          end
        end

        Callback_.stream do

          if d < len
            x = a.fetch d
            d += 1
            x
          end
        end
      end

      def exist? s
        ::File.exist? s
      end

      def expand_path fn, ds=nil
        ::File.expand_path fn, ds
      end

      def file? s
        ::File.file? s
      end

      def glob * a
        ::Dir.glob( * a )
      end

      def pwd
        ::Dir.pwd
      end

      def stat path
        ::File::Stat.new path
      end

      # ~ write :+#core-services

      def mkdir path, * int
        ::Dir.mkdir path, * int
      end

      def mkdir_p path, & oes_p  # experimental alternative to f.u
        FS_::Actors_::Mkdir_p[ path, self, & oes_p ]
      end

      def rmdir path
        ::Dir.rmdir path
      end

      def mv src, dst, h=nil, & x_p

        if x_p
          file_utils_controller do | msg |

            x_p.call :info, :file_utils_message do

              _ev = Callback_::Event.wrap.file_utils_message msg
              _ev or Callback_::Event.inline_neutral_with( :fu_msg, :msg, msg )
            end
            NIL_
          end.mv src, dst, * h
        else

          Home_.lib_.file_utils.mv src, dst, * h
        end
      end

      def copy src_s, dst_s
        ::File.copy_stream src_s, dst_s
      end

      def open filename, * rest, & p
        ::File.open filename, * rest, & p
      end

      def unlink path
        ::File.unlink path
      end

      # ~ etc :+#core-services

      def path_is_absolute path

        # (this is a placeholder for the idea)

        FILE_SEPARATOR_BYTE == path.getbyte( 0 )
      end

      # <-

    Autoloader_[ Actors_ = ::Module.new ]
    Autoloader_[ Bridges_ = ::Module.new ]
    Autoloader_[ Normalizations_ = ::Module.new ]
    Autoloader_[ Sessions_ = ::Module.new ]

    ACHIEVED_ = true
    CONST_SEP_ = '::'
    DIRECTORY_FTYPE = 'directory'.freeze
    DOT_ = '.'.freeze
    DOT_DOT__ = '..'
    FILE_FTYPE = 'file'
    FILE_SEPARATOR_BYTE = ::File::SEPARATOR.getbyte 0
    FS_ = self
    IDENTITY_ = -> x { x }
    NIL_ = nil

  end
end
