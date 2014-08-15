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
    Basic_Fields = -> * x_a do
      if x_a.length.zero?
        MetaHell__[]::Basic_Fields
      else
        MetaHell__[]::Basic_Fields.via_iambic x_a
      end
    end
    Brazen__ = sidesys[ :Brazen ]
    CLI = -> do
      Headless__[]::CLI
    end
    CLI_legacy_DSL = -> mod do
      Porcelain__[]::Legacy::DSL[ mod ]
    end
    CLI_path_tools = -> do
      Headless__[]::CLI::PathTools
    end
    Dev_null = -> do
      Headless__[]::IO::DRY_STUB
    end
    EN_mini = -> do
      NLP[]::EN::Minitesimal
    end
    Entity = -> do
      Brazen__[]::Entity
    end
    Funcy_globless = -> x do
      MetaHell__[].funcy_globless x
    end
    Formal_attribute = -> do
      MetaHell__[]::Formal::Attribute
    end
    Formal_box = -> do
      MetaHell__[]::Formal::Box
    end
    Headless__ = sidesys[ :Headless ]
    IO_FU = -> do
      Headless__[]::IO::FU
    end
    Name = -> do
      Headless__[]::Name
    end
    NLP = -> do
      Headless__[]::NLP
    end
    Memoize = -> p do
      MetaHell__[]::FUN.memoize[ p ]
    end
    MetaHell__ = sidesys[ :MetaHell ]
    Model_event = -> mod do
      Headless__[]::Model::Event.apply_on_client mod
    end
    Porcelain__ = sidesys[ :Porcelain ]
    Pretty_path = -> x do
      Brazen__[]::CLI.pretty_path x
    end
    Strange = -> x do
      MetaHell__[].strange x
    end
    Sub_client = -> do
      Headless__[]::SubClient  # :+#deprecation:watch
    end
    SubTree__ = sidesys[ :SubTree ]
    Text_patch = -> do
      Headless__[]::Text::Patch
    end
    Tmpdir_pathname = -> do
      Headless__[]::System.defaults.tmpdir_pathname
    end
    Tree = -> do
      SubTree__[]::Tree
    end
    Writemode = -> do
      Headless__[]::WRITEMODE_
    end
  end
end
