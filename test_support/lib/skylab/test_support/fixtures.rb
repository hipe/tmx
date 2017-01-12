module Skylab::TestSupport

  module Fixtures  # :[#037] (manifest has some notes about content guarantees)

    class << self

      def directory sym
        ::File.join @dirs_path, __dirs_box.fetch( sym )
      end

      def file sym
        ::File.join @files_path, __files_box.fetch( sym )
      end

      def tree sym
        ::File.join @trees_path, __trees_box.fetch( sym )
      end

      def tree_path_via_entry s
        ::File.join @trees_path, s
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

      def __trees_box
        @___trees_box ||= _build_box @trees_path
      end

      def _build_box path_head

        bx = Common_::Box.new

        ::Dir.glob( "#{ path_head }/*" ).each do |path|

          bn = ::File.basename path
          ext = ::File.extname bn
          d = ext.length
          _stem = d.zero? ? bn : bn[ 0 ... -d ]
          bx.add _stem.gsub( DASH_, UNDERSCORE_ ).intern, bn
        end

        bx
      end
    end  # >>

    dir = ::File.expand_path '../../..', Home_.dir_path

    @dirs_path = ::File.join( dir, 'fixture-directories' ).freeze
    @files_path = ::File.join( dir, 'fixture-files' ).freeze
    @trees_path = ::File.join( dir, 'fixture-trees' ).freeze

  end
end
