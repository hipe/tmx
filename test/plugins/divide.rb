module Skylab::Test

  class Plugins::Divide

    Headless::Plugin.enhance self do
      eventpoints %i|
        available_actions
        action_summaries
        argv_hijinx
      |
      service_names %i|
        infostream
        paystream
        hot_subtree
        full_program_name
      |
    end

    available_actions [ [ :divide, 0.1700 ] ]

    action_summaries( divide: "break it up into smaller pieces (try it)" )

    include Agent_IM_

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
      if ! self.class.respond_to? :dir_pathname  # circ.
        Face::MAARS::Upwards[ self.class ]
      end
      self.class.const_get( :Worker_, false )[ host, @argv ]
      false  # do not continue
    end
  end
end
