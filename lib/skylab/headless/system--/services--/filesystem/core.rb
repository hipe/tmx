module Skylab::Headless

  module System__

    class Services__::Filesystem  # :[#130].

      def initialize system
        @system = system
      end

      def cache
        Filesystem_::Cache__
      end

      def constants
        Filesystem_
      end

      # ~ read :+#core-services

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

      def file? s
        ::File.file? s
      end

      def glob * a
        ::Dir.glob( * a )
      end

      # ~ write :+#core-services

      def mkdir path, * int
        ::Dir.mkdir path, * int
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
          file_utils_controller.mv src, dst, * h
        end
      end

      def copy src_s, dst_s
        ::File.copy_stream src_s, dst_s
      end

      def open filename, * rest, & p
        ::File.open filename, * rest, & p
      end

      # ~

      def file_utils_controller & p
        if p
          Filesystem_::File_Utils_Controller__.new p
        else
          Filesystem_::File_Utils_Controller__
        end
      end

      def find * x_a, & oes_p
        if x_a.length.zero?
          Filesystem_::Find__
        else
          Filesystem_::Find__.mixed_via_iambic x_a, & oes_p
        end
      end

      def flock_first_available_path * x_a
        if x_a.length.zero?
          Filesystem_::Flock_first_available_path__
        else
          Filesystem_::Flock_first_available_path__.call_via_iambic x_a
        end
      end

      def grep * x_a
        Filesystem_::Grep__.mixed_via_iambic x_a
      end

      def hack_guess_module_tree * x_a, & oes_p
        Filesystem_::Hack_guess_module_tree__.call_via_arglist x_a, & oes_p
      end

      def line_stream_via_path path, num_bytes=nil
        Headless_::IO.line_stream ::File.open( path, ::File::RDONLY ), num_bytes
      end

      def line_stream_via_pathname pn, num_bytes=nil
        Headless_::IO.line_stream pn.open( ::File::RDONLY ), num_bytes
      end

      def members
        self.class.instance_methods false  # neat
      end

      def normalization
        Filesystem_::Normalization__
      end

      def path_tools
        Filesystem_::Path_Tools__
      end

      def tmpdir * x_a, & x_p

        case 1 <=> x_a.length
        when -1
          Filesystem_::Tmpdir__.new_via_iambic x_a, & x_p
        when  0
          x_a.unshift :path
          Filesystem_::Tmpdir__.new_via_iambic x_a, & x_p
        when  1
          Filesystem_::Tmpdir__
        end
      end

      def tmpdir_path
        @tmpdir_path ||= tmpdir_pathname.to_path
      end

      def tmpdir_pathname
        @tmpdir_pathname ||= ::Pathname.new Headless_::Library_::Tmpdir.tmpdir
      end

      def walk * x_a, & oes_p
        if x_a.length.nonzero? || block_given?
          Filesystem_::Walk__.call_via_iambic x_a, & oes_p
        else
          Filesystem_::Walk__
        end
      end

      DIRECTORY_FTYPE = 'directory'.freeze

      DOT_ = '.'.freeze

      DOT_DOT__ = '..'

      FILE_FTYPE = 'file'

      FILE_SEPARATOR_BYTE = ::File::SEPARATOR.getbyte 0

      Filesystem_ = self

      NIL_ = nil

    end
  end
end
