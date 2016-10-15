module Skylab::Cull::TestSupport

  module Fixtures

    module Directories

      class << self
        def [] sym
          _tail = sym.id2name.gsub UNDERSCORE_, DASH_
          ::File.join dir_path, _tail
        end
      end  # >>

      Home_::Autoloader_[ self ]

    end

    module Files

      define_singleton_method :[], ( -> do

        p = -> sym do

          path = Files.dir_path
          path_a = ::Dir.glob( "#{ path }/*" )
          h = {}
          path_a.each do | path_ |
            s = ::File.basename path_
            h[ s.gsub( BLACK_RX__, UNDERSCORE_ ).intern ] = s
          end
          p = -> sym_ do
            ::File.join path, h.fetch( sym_ )
          end
          p[ sym ]
        end

        -> sym do
          p[ sym ]
        end
      end ).call

      BLACK_RX__ = /[^[:alnum:]]/

      Home_::Autoloader_[ self ]

    end

    module Patches

      class << self
        def [] sym
          _tail = "#{ sym.id2name.gsub( UNDERSCORE_, DASH_ ) }.patch"
          ::File.join dir_path, _tail
        end
      end  # >>

      Home_::Autoloader_[ self ]

    end

    DOT_ = '.'.freeze
  end
end
