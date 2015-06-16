module Skylab::Git

  module Library_

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

    Basic = sidesys[ :Basic ]

    Box = -> do
      Basic[]::Box
    end

    Bin_pathname = -> do
      System[].defaults.bin_pathanem
    end

    Brazen = sidesys[ :Brazen ]

    Bundle = -> do
      Plugin[]::Bundle
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

    Fields = sidesys[ :Fields ]

    FUC = -> do
      System[].filesystem.file_utils_controller
    end

    HL__ = sidesys[ :Headless ]

    MH__ = sidesys[ :MetaHell ]

    Parse_lib = sidesys[ :Parse ]

    Path_tools = -> do
      System[].filesystem.path_tools
    end

    Plugin = sidesys[ :Plugin ]

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
      Basic[]::Set
    end

    Struct = -> * i_a do
      Basic[]::Struct.make_via_arglist i_a
    end

    System = -> do
      System_lib__[].services
    end

    System_lib__ = sidesys[ :System ]

    Word_wrap = -> do
      Basic[]::String.word_wrap
    end
  end
end
