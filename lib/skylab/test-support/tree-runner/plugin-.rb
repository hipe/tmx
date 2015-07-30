module Skylab::TestSupport

  class Tree_Runner

    sl_lib = ::File.expand_path '../..', HERE_  # [#002] #at-this-exact-point

    require "#{ sl_lib }/test-support/core"

    Autoloader_[ self ]

    Autoloader_[ Plugins__, :boxxy ]

    module Lib_  # :+[#ss-001]

      sidesys = Autoloader_.build_require_sidesystem_proc

      Basic = sidesys[ :Basic ]

      Human  = sidesys[ :Human ]

      HL__ = sidesys[ :Headless ]

      Open3 = -> do
        require 'open3'
        ::Open3
      end

      Option_parser = -> do
        require 'optparse'
        ::OptionParser
      end

      Tree_Runner::Plugin___ = sidesys[ :Plugin ]

      System = -> do
        System_lib__[].services
      end

      System_lib__ = sidesys[ :System ]

    end  # Lib_

    # ~

    Plugin_ = Plugin___[]::Digraphic

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
