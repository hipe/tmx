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

    module Patches

      class << self
        def [] sym
          dir_pathname.join( "#{ sym.id2name.gsub( UNDERSCORE_, DASH_ ) }.patch" ).to_path
        end
      end

      Cull_::Autoloader_[ self ]

    end
  end
end
