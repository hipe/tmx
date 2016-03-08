module Skylab::Snag

  module Library_

    stdlib = Autoloader_.method :require_stdlib

    o = { }
    o[ :DateTime ] = stdlib
    o[ :FileUtils ] = stdlib
    o[ :Open3 ] = stdlib
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Shellwords ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }

    define_singleton_method :const_missing do | sym |

      p = o[ sym ]
      if p
        const_set sym, p[ sym ]
      else
        super
      end
    end
  end

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    A_short_length = -> do
      Basic[]::String.a_reasonably_short_length_for_a_string
    end

    Autonomous_component_system = sidesys[ :Autonomous_Component_System ]

    Basic = sidesys[ :Basic ]
    Fields = sidesys[ :Fields ]
    Brazen = sidesys[ :Brazen ]

    CLI_legacy_DSL = -> mod do
      Porcelain__[]::Legacy::DSL[ mod ]
    end

    EN_mini = -> do
      NLP[]::EN
    end

    Entity = -> do
      Brazen[]::Entity
    end

    Event = -> do
      Brazen[].event
    end

    FUC = -> do
      System[].filesystem.file_utils_controller
    end

    Hu__ = sidesys[ :Human ]

    NLP = -> do
      Hu__[]::NLP
    end

    Parse_lib = sidesys[ :Parse ]

    Patch_lib = -> do
      System[].filesystem.patch
    end

    Path_tools = -> do
      System[].filesystem.path_tools
    end

    Pretty_path = -> x do
      Brazen[]::CLI.pretty_path x
    end

    Strange = -> * x_a do
      Basic[]::String.via_mixed.call_via_arglist x_a
    end

    String_lib = -> do
      Basic[]::String
    end

    system_lib = sidesys[ :System ]

    System = -> do
      system_lib[].services
    end

    class << self
      attr_reader :instance
    end  # >>

    @instance = Callback_.produce_library_shell_via_library_and_app_modules(
      self, Home_ )
  end

  LIB_ = Lib_.instance
end
