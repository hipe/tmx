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
      HL__[]::Action.apply_iambic_on_client x_a, client
    end

    Bsc__ = sidesys[ :Basic ]

    Basic_fields = -> * x_a do
      if x_a.length.zero?
        MH__[]::Basic_Fields
      else
        MH__[]::Basic_Fields.via_iambic x_a
      end
    end

    Box = -> do
      Bsc__[]::Box
    end

    Bin_pathname = -> do
      System[].defaults.bin_pathanem
    end

    Bundle = -> do
      MH__[]::Bundle
    end

    CLI_lib = -> do
      HL__[]::CLI
    end

    CLI_program_basename = -> do
      Face__[].program_basename
    end

    CLI_std_two = -> do
      Face__[].stdout_stderr
    end

    Client = -> client, * x_a do
      HL__[]::Client.apply_iambic_on_client x_a, client
    end

    Face__ = sidesys[ :Face ]

    FUC = -> do
      System[].filesystem.file_utils_controller
    end

    Funcy_globful = -> x do
      MH__[].funcy_globful x
    end

    Funcy_globless = -> x do
      MH__[].funcy_globless x
    end

    Fuzzy_matcher = -> x, y do
      MH__[]::Parse.fuzzy_matcher[ x, y ]
    end

    HL__ = sidesys[ :Headless ]

    MH__ = sidesys[ :MetaHell ]

    Path_tools = -> do
      System[].filesystem.path_tools
    end

    Plugin = -> do
      HL__[]::Plugin
    end

    Scanner = -> x do
      Callback_::Scn.try_convert x
    end

    Scn = -> do
      Callback_::Scn
    end

    Service_terminal = -> do
      HL__[]::Service_Terminal
    end

    Set = -> do
      Bsc__[]::Set
    end

    Struct = -> * i_a do
      Bsc__[]::Struct.make_via_arglist i_a
    end

    System = -> do
      HL__[].system
    end

    Word_wrap = -> do
      Bsc__[]::String.word_wrap
    end
  end
end
