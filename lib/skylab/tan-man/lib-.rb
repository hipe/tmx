module Skylab::TanMan

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Entity = -> do
      Brazen_::Entity
    end

    Event_builder = -> x do
      x.include Brazen_::Entity::Event::Builder_Methods ; nil
    end

    Home_directory_pathname = -> do
      HL__[]::System.system.any_home_directory_pathname
    end

    HL__ = sidesys[ :Headless ]

    Two_streams = -> do
      HL__[]::System::IO.some_two_IOs
    end

  end
end
