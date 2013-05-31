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

    include CLI::SubClient::InstanceMethods

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
      tablify(
        [ 'subproduct', 'num test files' ],
        ( ::Enumerator.new do |y|
          total = 0
          ok = host.hot_subtree.children.each do |tre|
            sp = tre.data
            num = tre.children.count
            if num.nonzero? or @do_zero
              total += num
              y.yield sp.slug, num
            end
          end
          y.yield '(total)', total
          ok
        end ),
        host.info_y.method( :<< )
      )
    end
  end
end
