module Skylab::TestSupport

  class Tree_Runner

    class Plugins__::Divide_The_Sidesystems < Plugin_

      does :flush_the_sidesystem_tree do | st |

        st.transition_is_effected_by do | o |

          o.on '--divide N', "output the sidesystems into N smaller systems"

        end
      end

      def do__flush_the_sidesystem_tree__
        @resources.serr.puts "(this is the divide plugin pretending to work)"
        ACHIEVED_
      end

      if false

    Plugin_.enhance self do

      eventpoints_subscribed_to( * %i|
        available_actions
        action_summaries
        argv_hijinx
      | )

      services_used(
        [ :infostream, :proxy ],
        [ :paystream, :proxy ],
        [ :hot_subtree, :proxy ],
        [ :full_program_name, :proxy ]
      )

    end

    available_actions [ [ :divide, 0.1700 ] ]

    action_summaries( divide: :x )

    def initialize
      @argv = nil
    end

    argv_hijinx do |cmd_i, argv|
      if :divide == cmd_i
        @argv = argv.dup
        argv.clear
      end
      nil
    end

    def divide
      self.class.const_get( :Back__, false )[ @plugin_parent_services, @argv ]
      false  # do not continue
    end

      end
    end
  end
end
