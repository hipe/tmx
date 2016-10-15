module Skylab::Cull::TestSupport

  module Fixtures

    HEAD__ = TS_.dir_path

    module Directories

      class << self
        def [] sym
          _tail = sym.id2name.gsub UNDERSCORE_, DASH_
          ::File.join @dir_path, _tail
        end
      end  # >>

      Autoloader_[ self, ::File.join( HEAD__, 'fixture-directories' ) ]
    end

    module Files

      define_singleton_method :[], ( -> do

        p = -> sym do

          dir = Files.dir_path

          path_a = ::Dir.glob( "#{ dir }/*" )

          h = {}

          path_a.each do |path|

            s = ::File.basename path
            _key = s.gsub( BLACK_RX__, UNDERSCORE_ ).intern
            h[ _key ] = s
          end

          p = -> sym_ do
            ::File.join dir, h.fetch( sym_ )
          end

          p[ sym ]
        end

        -> sym do
          p[ sym ]
        end
      end ).call

      BLACK_RX__ = /[^[:alnum:]]/

      Autoloader_[ self, ::File.join( HEAD__, 'fixture-files' ) ]
    end

    module Patches

      class << self
        def [] sym
          _tail = "#{ sym.id2name.gsub( UNDERSCORE_, DASH_ ) }.patch"
          ::File.join @dir_path, _tail
        end
      end  # >>

      Autoloader_[ self, ::File.join( HEAD__, 'fixture-patches' ) ]
    end

    DOT_ = '.'.freeze
  end
end
