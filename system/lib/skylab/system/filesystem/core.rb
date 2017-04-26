module Skylab::System

  module Filesystem  # #[#sl-155]

  class Service  # see [#009]

    def initialize _svx
    end

    # ~ actor exposures

    def flock_first_available_path *a, &p

      Home_::Filesystem::Flock_first_available_path.against_mutable_ a, &p
    end

    def hack_guess_module_tree *a, &p

      Home_::Filesystem::Hack_guess_module_tree.against_mutable_ a, &p
    end

    # ~ bridge exposures

    def cache
      @___cache ||= Home_::Filesystem::Cache.new self
    end

    def file_utils_controller & x_p

      Home_::Filesystem::File_Utils_Controller.for_any_proc_( & x_p )
    end

    # ~ model exposures

    ## ~~ tmpdir

    def tmpdir_path
      @__tmpdir_path ||= Home_.lib_.tmpdir_path
    end

    # ~ hook-outs / internal / low-level

    def modality_const
      :Filesystem
    end

    # - core services

      # ~ peripheral but nearby

      def line_stream_via_path path, num_bytes=nil

        _io = open path, ::File::RDONLY  # *NOT* the kernel method, ours
        Home_::IO::LineStream_via_PageSize.call_by do |o|
          o.filehandle = _io
          o.page_size = num_bytes
        end
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

          if DOT_DOT_ == a[ d ]
            d += 1
          end
        end

        Common_.stream do

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
        Home_::Filesystem::Mkdir_p[ path, self, & oes_p ]
      end

      def rmdir path
        ::Dir.rmdir path
      end

      def mv src, dst, h=nil, & p

        if p
          _fuc = file_utils_controller do |msg|

            p.call :info, :file_utils_message do
              ev = Common_::Event.wrap.file_utils_message msg
              if ev
                ev
              else
                Common_::Event.inline_neutral_with :fu_msg, :msg, msg
              end
            end
            NIL
          end
          _fuc.mv src, dst, * h
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

      define_method :path_looks_absolute, Path_looks_absolute_

      define_method :path_looks_relative, Path_looks_relative_

    # - end core services
  end

    Autoloader_[ self ]
    lazily :ByteDownstreamReference do
      Filesystem::ByteUpstreamReference::ByteDownstreamReference_STOWED_AWAY
    end

    # ==

    CONST_SEP_ = '::'
    DIRECTORY_FTYPE = 'directory'
    DOT_ = '.'
    DOT_DOT_ = '..'
    FILE_FTYPE = 'file'

    # ==
  end
end
