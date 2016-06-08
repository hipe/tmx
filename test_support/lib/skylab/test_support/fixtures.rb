module Skylab::TestSupport

  module Fixtures

    class << self

      def dir sym
        ::File.join @dirs_path, __dirs_box.fetch( sym )
      end

      def file sym
        ::File.join @files_path, __files_box.fetch( sym )
      end

      attr_reader(
        :dirs_path,
        :files_path,
      )

      def __dirs_box
        @___dirs_box ||= ___build_dirs_box
      end

      def ___build_dirs_box
        bx = _build_box @dirs_path
        bx.add :not_here, 'not-here.d'  # guaranteed never to exist
        bx
      end

      def __files_box
        @___files_box ||= ___build_files_box
      end

      def ___build_files_box
        bx = _build_box @files_path
        bx.add :not_here, 'not-here.file'  # guaranteed never to exist
        bx
      end

      def _build_box path_head

        bx = Common_::Box.new

        ::Dir.glob( "#{ path_head }/*" ).each do | path |

          bn = ::File.basename path
          ext = ::File.extname bn
          _stem = bn[ 0 ... - ( ext.length ) ]

          bx.add _stem.gsub( DASH_, UNDERSCORE_ ).intern, bn
        end

        bx
      end
    end  # >>

    _dir_path = ::File.expand_path '../../..', Home_.dir_pathname.to_path

    @files_path = ::File.join( _dir_path, 'fixture-files' ).freeze

    @dirs_path = ::File.join( _dir_path, 'fixture-directories' ).freeze

  end
end
