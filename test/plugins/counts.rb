module Skylab::Test

  module Plugins::Counts

    Headless::Plugin.enhance self do

      eventpoints_subscribed_to( * %i|
        available_options
        available_actions
        action_summaries
      | )

      services_used(
        :info_y,
        :hot_subtree
      )

    end
  end

  class Plugins::Counts::Client

    available_options do |o, _|

      o.on '-z', '--zero', 'display the zero values (when counting)' do
        @do_zero = true
      end

      true
    end

    available_actions [
      [ :counts, 0.1666 ]
    ]

    action_summaries(
      counts: "show a report of the number of tests per subproduct"
    )

    def initialize
      @do_zero ||= nil
    end

    def counts
      Face::CLI::Table::FUN.tablify[
        [[ :fields, [ 'subproduct', 'num test files' ]]],
        info_y.method( :<< ),
        ::Enumerator.new do |y|
          total = 0 ; hs = hot_subtree
          ok = hs.children.each do |tre|
            sp = tre.data
            num = tre.children.count
            if num.nonzero? or @do_zero
              total += num
              y << [ sp.slug, num.to_s ]
            end
          end
          y << [ '(total)', total.to_s ]
          ok
        end  ]
    end
  end
end
