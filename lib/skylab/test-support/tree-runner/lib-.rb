module Skylab::TestSupport

  class Tree_Runner

    sl_lib = ::File.expand_path '../..', HERE_ # [#002] #at-this-exact-point

    require "#{ sl_lib }/test-support/core"

    Autoloader_[ self ]

    Autoloader_[ Plugins__, :boxxy ]

    module Lib_  # :+[#ss-001]

      sidesys = Autoloader_.build_require_sidesystem_proc

      CLI_lib = -> do
        HL__[]::CLI
      end

      HL__ = sidesys[ :Headless ]

      NLP = -> do
        HL__[]::NLP
      end

      Oxford_and = -> a do
        Callback_::Oxford_and[ a ]
      end

      Option_parser = -> do
        require 'optparse'
        ::OptionParser
      end

      if false

    Bsc__ = sidesys[ :Basic ]

    Basic_Mutex = -> do
      Bsc__[]::Mutex
    end

    Basic_Tree = -> do
      Bsc__[]::Tree
    end


    EN_calculate = -> & p do
      HL__[].expression_agent.NLP_EN_agent.calculate( & p )
    end

    Face__ = sidesys[ :Face ]


    Heavy_plugin = -> do
      Face__[]::Plugin
    end

    MH__ = sidesys[ :MetaHell ]


    Parse_lib = -> do
      MH__[]::Parse
    end

    Pretty_path_proc = -> do
      HL__[].system.filesystem.path_tools.pretty_path
    end

    Reparenthesize = -> p, msg do
      Face__[]::CLI.reparenthesize[ p, msg ]
    end

    Set = stdlib[ :Set ]

    Spec_rb = -> do
      TestSupport__[].spec_rb
    end

    TestSupport__ = sidesys[ :TestSupport ]

    Touch_const = -> do
      MH__[].touch_const
    end

      end
    end  # Lib_

    # ~

    Plugin_ = Lib_::HL__[]::Plugin

    Plugins__::Express_Help = Plugin_::Express_Help

  end
end
