module Skylab::SubTree

  module Library_  # :+[#su-001]

    stdlib = Autoloader_.method :require_stdlib

    o = {}
    o[ :StringIO ] = stdlib

    define_singleton_method :const_missing do | sym |
      const_set sym, o.fetch( sym )[ sym ]
    end
  end

  module Lib_

    _memo, sidesys = Autoloader_.at :memoize, :build_require_sidesystem_proc

    Brazen = sidesys[ :Brazen ]

    CLI_lib = -> do
      HL__[]::CLI
    end

    HL__ = sidesys[ :Headless ]

    INSTANCE = Callback_.produce_library_shell_via_library_and_app_modules(
      self, SubTree_ )  # at the end

  end
end
