module Skylab::System

  const_get :Filesystem, false
  module Filesystem  # #[#sl-155]

  class Services___::Filesystem  # see [#009]

    def initialize _svx
    end

    # ~ actor exposures

    def flock_first_available_path * x_a, & x_p

      Home_::Filesystem::Flock_first_available_path.for_mutable_args_ x_a, & x_p
    end

    def hack_guess_module_tree * x_a, & x_p

      Home_::Filesystem::Hack_guess_module_tree.for_mutable_args_ x_a, & x_p
    end

    # ~ normalization exposures

    def for_mutable_args_ x_a

      if x_a.length.zero?
        self
      else
        normalization( * x_a )
      end
    end

    # ~ bridge exposures

    def cache
      @___cache ||= Home_::Filesystem::Cache.new self
    end

    def file_utils_controller & x_p

      Home_::Filesystem::File_Utils_Controller.for_any_proc_( & x_p )
    end

    # ~ model exposures

    ## ~~ dir as collection

    def directory_as_collection & build

      Home_::Filesystem::Directory::As::Collection.new do |o|
        o.filesystem = self  # as a default
        build[ o ]
      end
    end

    ## ~~ tmpdir

    def tmpdir_path
      @__tmpdir_path ||= Home_.lib_.tmpdir
    end

    def tmpdir * x_a, & x_p

      Home_::Filesystem::Tmpdir.for_mutable_args_ x_a, & x_p
    end

    def normalization sym  # [#]:note-C

      _cls = Home_::Filesystem::Normalizations.const_get sym, false
      _cls.begin_ self
    end

    # ~ session exposures

    def tmpfile_sessioner
      Home_::Filesystem::Tmpfile_Sessioner
    end

    def walk * x_a, & oes_p
      Home_::Filesystem::Walk.for_mutable_args_ x_a, & oes_p
    end

    # ~ hook-outs / internal / low-level

    def constants
      Home_::Filesystem
    end

    def modality_const
      :Filesystem
    end

    # - core services

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

          if DOT_DOT_ == a[ d ]
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
        Home_::Filesystem::Mkdir_p[ path, self, & oes_p ]
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

    # - end core services
  end
  end
end
