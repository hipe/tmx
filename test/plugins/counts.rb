module Skylab::Test

  module Plugins::Counts

    Plugin_.enhance self do

      eventpoints_subscribed_to( * %i|
        available_options
        available_actions
        action_summaries
      | )

      services_used(
        :info_y,
        :hot_subtree,
        :paystream
      )

    end
  end

  class Plugins::Counts::Client

    available_options do |o, _|

      o.on '-v', '--verbose', 'show max share meter (experimental)' do
        @verbosity_level += 1
      end

      o.on '-V', 'reduce verbosity level' do
        @verbosity_level -= 1
      end

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
      @verbosity_level = 1
      @do_zero ||= nil
    end

    def counts
      if 1 < @verbosity_level
        field_extra = bld_max_share_meter_args
        total_line_extra = [ nil ]
        do_meter = true
      end
      Test_::Lib_::CLI_table[
        :field, 'subproduct',
        :field, 'num test files',
        * field_extra,
        :write_lines_to, paystream.method( :puts ),
        :read_rows_from, ::Enumerator.new do |y|
          total = 0 ; hs = hot_subtree
          ok = hs.children.each do |tre|
            sp = tre.data
            num = tre.children.count
            if num.nonzero? or @do_zero
              total += num
              if do_meter
                y << [ sp.slug, num, num ]
              else
                y << [ sp.slug, num ]
              end
            end
          end
          y << [ '(total)', total, * total_line_extra ]
          ok
        end  ]
      if 1 == @verbosity_level
        info_y << '("-v" for visualization, "-V" hides this message)'
      end
      nil
    end
  private
    def bld_max_share_meter_args
      _width = Test_::Lib_::CLI_table[].some_screen_width
      [ :target_width, _width, :field, :fill,
        :cel_renderer_builder, :max_share_meter ]
    end
  end
end
