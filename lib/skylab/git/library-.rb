module Skylab::Git

  module Library_  # :+[#su-001]

    stdlib, = Autoloader_.at :require_stdlib

    o = { }
    o[ :FileUtils ] = stdlib
    o[ :Open3 ] = stdlib
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Set ] = o[ :Shellwords ] = o[ :StringIO ] = stdlib

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
    end
  end

  module Lib_
    sidesys = Autoloader_.build_require_sidesystem_proc
    Action = -> client, * x_a do
      Headless__[]::Action.apply_iambic_on_client x_a, client
    end
    Basic__ = sidesys[ :Basic ]
    Basic_Fields = -> * x_a do
      if x_a.length.zero?
        MetaHell__[]::Basic_Fields
      else
        MetaHell__[]::Basic_Fields.via_iambic x_a
      end
    end
    Box = -> do
      Basic__[]::Box
    end
    Bin_pathname = -> do
      Headless__[]::System.defaults.bin_pathname
    end
    Bundle = -> do
      MetaHell__[]::Bundle
    end
    CLI = -> do
      Headless__[]::CLI
    end
    CLI_program_basename = -> do
      Face__[]::FUN.program_basename[]
    end
    CLI_std_two = -> do
      o = Face__[]::FUN
      [ o::Stdout[], o::Stderr[] ]
    end
    Client = -> client, * x_a do
      Headless__[]::Client.apply_iambic_on_client x_a, client
    end
    Face__ = sidesys[ :Face ]
    FUN_module = -> do
      MetaHell__[]::FUN::Module
    end
    Funcy_globful = -> x do
      MetaHell__[]::Funcy[ x ]
    end
    Funcy_globless = -> x do
      MetaHell__[]::Funcy_globless[ x ]
    end
    Fuzzy_matcher = -> x, y do
      MetaHell__[]::FUN::Parse::Fuzzy_matcher[ x, y ]
    end
    Headless__ = sidesys[ :Headless ]
    IO_FU = -> do
      Headless__[]::IO::FU
    end
    MetaHell__ = sidesys[ :MetaHell ]
    Plugin = -> do
      Headless__[]::Plugin
    end
    Scanner = -> x do
      Basic__[]::List::Scanner[ x ]
    end
    Scn = -> do
      Callback_::Scn
    end
    Service_terminal = -> do
      Headless__[]::Service_Terminal
    end
    Set = -> do
      Basic__[]::Set
    end
    Struct = -> * i_a do
      Basic__[]::Struct.from_i_a i_a
    end
    Word_wrap = -> do
      Headless__[]::Text::Word_Wrap
    end
  end
end
