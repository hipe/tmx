module Skylab::Cull::TestSupport

  module Fixtures

    AREF__ = -> sym do

      dir_pathname.join( sym.id2name.gsub( UNDERSCORE_, DASH_ ) ).to_path

    end

    module Directories

      define_singleton_method :[], AREF__

      Cull_::Autoloader_[ self ]

    end

    module Patches

      Cull_::Autoloader_[ self ]

    end
  end
end
