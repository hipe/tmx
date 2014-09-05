module Skylab::TanMan

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Entity = -> do
      Brazen_::Entity
    end

    Home_directory_pathname = -> do
      HL__[]::System.system.any_home_directory_pathname
    end

    HL__ = sidesys[ :Headless ]

  end
end
