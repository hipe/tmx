module Skylab::MetaHell

  module Lib_

    sidesys, stdlib = Autoloader_.at :build_require_sidesystem_proc,
      :build_require_stdlib_proc

    Basic = sidesys[ :Basic ]

    Brazen = sidesys[ :Brazen ]

    Entity_lib = -> do
      Brazen[]::Entity
    end

    Levenshtein = -> do
      IT__[]::Levenshtein
    end

    List_lib = -> do
      Basic[]::List
    end

    HL__ = sidesys[ :Headless ]

    IT__ = sidesys[ :InformationTactics ]

    Meso_box_lib = -> do
      Basic[]::Box
    end

    Module_lib = -> do
      Basic[]::Module
    end

    Mutex_lib = -> do
      Basic[]::Mutex
    end

    Proxy_lib = -> do
      Callback_::Proxy
    end

    Stdlib_set = stdlib[ :Set ]

    Struct_lib = -> do
      Basic[]::Struct
    end

  end
end
