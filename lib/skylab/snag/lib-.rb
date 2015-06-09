module Skylab::Snag

  module Library_

    stdlib, subsystem = Autoloader_.at :require_stdlib, :require_sidesystem

    o = { }
    o[ :Basic ] = subsystem
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

    Basic = sidesys[ :Basic ]

    Basic_fields = -> * x_a do
      if x_a.length.zero?
        MH__[]::Basic_Fields
      else
        MH__[]::Basic_Fields.call_via_iambic x_a
      end
    end

    Brazen = sidesys[ :Brazen ]

    CLI_legacy_DSL = -> mod do
      Porcelain__[]::Legacy::DSL[ mod ]
    end

    CLI_lib = -> do
      HL__[]::CLI
    end

    Dev_null = -> do
      HL__[]::IO.dry_stub_instance
    end

    EN_mini = -> do
      NLP[]::EN
    end

    NLP_EN_methods = -> mod, * x_a do
      HL__[].expression_agent.NLP_EN_methods.on_mod_via_iambic mod, x_a
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

    Funcy_globless = -> x do
      MH__[].funcy_globless x
    end

    Formal_attribute = -> do
      MH__[]::Formal::Attribute
    end

    HL__ = sidesys[ :Headless ]

    Hu__ = sidesys[ :Human ]

    NLP = -> do
      Hu__[]::NLP
    end

    MH__ = sidesys[ :MetaHell ]

    Model_event = -> mod do
      HL__[]::Model::Event.apply_on_client mod
    end

    Parse_lib = sidesys[ :Parse ]

    Patch_lib = -> do
      System[].patch
    end

    Path_tools = -> do
      System[].filesystem.path_tools
    end

    Plugin = -> do
      HL__[]::Plugin
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

    System = -> do
      System_lib___[].services
    end

    System_lib___ = sidesys[ :System ]

    Tmpdir_pathname = -> do
      System[].filesystem.tmpdir_pathname
    end

    class << self
      attr_reader :instance
    end  # >>

    @instance = Callback_.produce_library_shell_via_library_and_app_modules(
      self, Snag_ )
  end

  LIB_ = Lib_.instance
end
