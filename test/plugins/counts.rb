module Skylab::Test

  module Plugins::Counts

    Headless::Plugin.enhance self do
      eventpoints %i|
        available_options
        available_actions
        action_summaries
      |
      service_names %i|
        info_y
        hot_subtree
      |
    end
  end

  class Plugins::Counts::Client

    include Face::CLI::Tableize::InstanceMethods  # `_tablify`

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

    include Agent_IM_

    def initialize
      @do_zero ||= nil
    end

    def counts
      _tablify [ 'subproduct', 'num test files' ],
        ( ::Enumerator.new do |y|
          total = 0
          ok = host.hot_subtree.children.each do |tre|
            sp = tre.data
            num = tre.children.count
            if num.nonzero? or @do_zero
              total += num
              y << [ sp.slug, num.to_s ]
            end
          end
          y << [ '(total)', total.to_s ]
          ok
        end ),
        host.info_y.method( :<< )
    end
  end
end
