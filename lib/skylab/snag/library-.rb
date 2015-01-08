module Skylab::Snag

  module Library_  # :+[#su-001]

    stdlib, subsystem = Autoloader_.at :require_stdlib, :require_sidesystem

    o = { }
    o[ :Basic ] = subsystem
    o[ :DateTime ] = o[ :FileUtils ] = o[ :Open3 ] = stdlib
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Porcelain__ ] = -> _ { subsystem[ :Porcelain ] }
    o[ :Shellwords ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }

    def self.const_missing c
      if (( p = self::H_[ c ] ))
        const_set c, p[ c ]
      else
        super
      end
    end

    H_ = o.freeze

    def self.kick ; end
  end

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    A_short_length = -> do
      Bsc__[]::String.a_reasonably_short_length_for_a_string
    end

    Bsc__ = sidesys[ :Basic ]

    Basic_fields = -> * x_a do
      if x_a.length.zero?
        MH__[]::Basic_Fields
      else
        MH__[]::Basic_Fields.via_iambic x_a
      end
    end

    Bound_call = -> * a do
      Bzn__[].bound_call.build_via_arglist a
    end

    Bzn__ = sidesys[ :Brazen ]

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
      Bzn__[]::Entity
    end

    Event = -> do
      Bzn__[].event
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

    Name = -> do
      HL__[]::Name
    end

    NLP = -> do
      HL__[]::NLP
    end

    MH__ = sidesys[ :MetaHell ]
    Model_event = -> mod do
      HL__[]::Model::Event.apply_on_client mod
    end

    Patch_lib = -> do
      System[].patch
    end

    Path_tools = -> do
      System[].filesystem.path_tools
    end

    Porcelain__ = sidesys[ :Porcelain ]

    Pretty_path = -> x do
      Bzn__[]::CLI.pretty_path x
    end

    Strange = -> * x_a do
      MH__[].strange.via_arglist x_a
    end

    String_lib = -> do
      Bsc__[]::String
    end

    SubTree__ = sidesys[ :SubTree ]

    System = -> do
      HL__[].system
    end

    Tmpdir_pathname = -> do
      System[].filesystem.tmpdir_pathname
    end

    Tree = -> do
      SubTree__[]::Tree
    end

    Writemode = -> do
      HL__[]::WRITE_MODE_
    end

    INSTANCE = Callback_.produce_library_shell_via_library_and_app_modules(
      self, Snag_ )
  end

  LIB_ = Lib_::INSTANCE
end
