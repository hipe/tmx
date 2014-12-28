module Skylab::Cull::TestSupport

  module Fixtures

    module Directories

      class << self
        def [] sym
          dir_pathname.join( sym.id2name.gsub( UNDERSCORE_, DASH_ ) ).to_path
        end
      end

      Cull_::Autoloader_[ self ]

    end

    module Files

      class << self
        def [] sym
          s = sym.id2name
          s[ s.rindex UNDERSCORE_ ] = DOT_
          s.gsub! UNDERSCORE_, DASH_
          dir_pathname.join( s ).to_path
        end
      end

      Cull_::Autoloader_[ self ]

    end

    module Patches

      class << self
        def [] sym
          dir_pathname.join( "#{ sym.id2name.gsub( UNDERSCORE_, DASH_ ) }.patch" ).to_path
        end
      end

      Cull_::Autoloader_[ self ]

    end

    DOT_ = '.'.freeze
  end
end
