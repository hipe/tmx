module Skylab::MetaHell

  module Lib_

    sidesys, stdlib = Autoloader_.at :build_require_sidesystem_proc,
      :build_require_stdlib_proc

    Basic = sidesys[ :Basic ]

    Brazen = sidesys[ :Brazen ]

    Entity_lib = -> do
      Brazen[]::Entity
    end

    Hu___ = sidesys[ :Human ]

    Levenshtein = -> do
      Hu___[]::Levenshtein
    end

    List_lib = -> do
      Basic[]::List
    end

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

    Strange = -> x do
      Basic[]::String.via_mixed x
    end

    Struct_lib = -> do
      Basic[]::Struct
    end

  end
end
