module Skylab::MetaHell

  module Lib_

    sidesys, stdlib = Autoloader_.at :build_require_sidesystem_proc,
      :build_require_stdlib_proc

    Bsc__ = sidesys[ :Basic ]

    Bzn__ = sidesys[ :Brazen ]

    CLI_lib = -> do
      HL__[]::CLI
    end

    Entity_lib = -> do
      Bzn__[]::Entity
    end

    Event_lib = -> do
      Callback_
    end

    Levenshtein = -> do
      IT__[]::Levenshtein
    end

    List_lib = -> do
      Bsc__[]::List
    end

    HL__ = sidesys[ :Headless ]

    IT__ = sidesys[ :InformationTactics ]

    Meso_box_lib = -> do
      Bsc__[]::Box
    end

    Method_added_muxer = -> * a do
      Bzn__[].method_added_muxer.via_arglist a
    end

    Module_lib = -> do
      Bsc__[]::Module
    end

    Mutex_lib = -> do
      Bsc__[]::Mutex
    end

    Old_name_lib = -> do
      HL__[]::Name
    end

    Proxy_lib = -> do
      Callback_::Proxy
    end

    Stdlib_set = stdlib[ :Set ]

    Struct_lib = -> do
      Bsc__[]::Struct
    end

  end
end
