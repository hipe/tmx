module Skylab::TestSupport

  class Tree_Runner

    # ~ [#002] #at-this-exact-point: manual loading is necessary..

    require 'skylab/test_support'

    if ! self.respond_to? :dir_pathname
      self._HELLO
      Autoloader_[ self ]
    end

    Autoloader_[ Plugins__, :boxxy ]

    # ~

    Plugin_ = Home_.lib_.plugin::Digraphic

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
