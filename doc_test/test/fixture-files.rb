module Skylab::DocTest::TestSupport

  module Fixture_Files

    def self.[] tcc
      tcc.include self
    end

    # -
      def line_stream_via_fixture_file_symbol_ sym
        _path = path_via_fixture_file_symbol_ sym
        ::File.open _path, ::File::RDONLY
      end

      def path_via_fixture_file_symbol_ sym
        ___fixture_file_path_cache.fetch sym
      end

      yes = true ; x = nil
      define_method :___fixture_file_path_cache do
        if yes
          yes = false
          x = PathCache___.new(
            ::File.join( TS_.dir_pathname.to_path, 'fixture-files' ),
            ::File,
            ::Dir,
          )
        end
        x
      end
    # -

    class PathCache___

      # kinda silly but allows us to use 'one', 'two' etc
      # from pathnames like "01-one-foo-dittily.file"

      def initialize path, fs, dir_fs

        h = {}
        st = Common_::Stream.via_nonsparse_array dir_fs.entries path

        dot = ".".getbyte 0  # skip '.' and '..' eew
        begin
          entry = st.gets
        end while dot == entry.getbyte( 0 )

        rx = /\A\d+-([a-z]+)/  # won't scale past 20 ("twenty-one" has a dash)
        begin
          md = rx.match entry
          h[ md[ 1 ].intern ] = entry
          entry = st.gets
        end while entry

        @_cache = {}
        @_entry_via_symbol = h
        @filesystem = fs
        @path = path
      end

      def fetch sym
        @_cache.fetch sym do
          x = ::File.join @path, @_entry_via_symbol.fetch( sym )
          @_cache[ sym ] = x
          x
        end
      end
    end
  end
end
