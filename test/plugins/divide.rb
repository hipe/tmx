module Skylab::Test

  class Plugins::Divide

    Test = Test  # so visible from children

    Divide = self

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

    action_summaries( divide: "break it up into smaller pieces (try it)" )

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
      self.class.const_get( :Worker_, false )[ @plugin_parent_services, @argv ]
      false  # do not continue
    end
  end
end
