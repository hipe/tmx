module Skylab::TestSupport

  class Tree_Runner

    sl_lib = ::File.expand_path '../..', HERE_  # [#002] #at-this-exact-point

    require "#{ sl_lib }/test-support/core"

    Autoloader_[ self ]

    Autoloader_[ Plugins__, :boxxy ]

    module Lib_  # :+[#ss-001]

      sidesys = Autoloader_.build_require_sidesystem_proc

      Basic = sidesys[ :Basic ]

      CLI_lib = -> do
        HL__[]::CLI
      end

      CLI_table = -> * x_a do
        if x_a.length.zero?
          Face__[]::CLI::Table
        else
          Face__[]::CLI::Table[ * x_a ]
        end
      end

      Face__ = sidesys[ :Face ]

      HL__ = sidesys[ :Headless ]

      NLP = -> do
        HL__[]::NLP
      end

      Open3 = -> do
        require 'open3'
        ::Open3
      end

      Option_parser = -> do
        require 'optparse'
        ::OptionParser
      end

      System = -> do
        HL__[].system
      end

      if false


    Basic_Mutex = -> do
      Bsc__[]::Mutex
    end

    Basic_Tree = -> do
      Bsc__[]::Tree
    end


    EN_calculate = -> & p do
      HL__[].expression_agent.NLP_EN_agent.calculate( & p )
    end



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

    class Plugins__::Express_Help < Plugin_

      does :finish do | st |

        st.transition_is_effected_by do | o |

          o.on '--help', 'show this screen'

        end
      end

      def do__finish__
        Plugin_.express_help_into @resources, & @on_event_selectively
      end
    end

    module Adapters_
      Autoloader_[ self ]
    end

    class Adapter_

      def initialize rsc, & oes_p
        @resources = rsc
        @on_event_selectively = oes_p
      end
    end
  end
end
