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
        @___dirs_box ||= _build_box( @dirs_path )
      end

      def __files_box
        @___files_box ||= _build_box( @files_path ).tap do |bx|
          bx.add :not_here, 'not-here.file'  # guaranteed never to exist
        end
      end

      def _build_box path_head

        bx = Callback_::Box.new

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
