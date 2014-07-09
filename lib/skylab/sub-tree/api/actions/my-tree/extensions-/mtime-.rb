module Skylab::SubTree

  class API::Actions::My_Tree

    class Extensions_::Mtime_

      SubTree::Lib_::Basic_Fields[ :client, self,
        :absorber, :absrb_iambic_fully,
        :field_i_a, [ :local_normal_name, :infostream, :verbose ]]

      def initialize x_a
        @now_t = SubTree::Library_::Time.new  # doesn't get cleared anywhere
        absrb_iambic_fully x_a ; nil
      end

      attr_reader :local_normal_name

      def is_post_notifiee
        false
      end

      def in_notify leaf
        stat = ::File::Stat.new leaf.input_line  # move into leaf if optimal
        seconds_old = @now_t - stat.mtime
        unit_i, amt_f = Lib_::Summarize_time[ seconds_old ]
        leaf.add_subcel "#{ amt_f.round } #{ ABBR_H_[ unit_i ] }"
        nil
      end
      #
      ABBR_H_ = {
        second: 'sec',
        minute: 'min',
        hour: 'hrs',
        day: 'day',
        week: 'wk',
        month: 'mon',
        year: 'yr',
      }.tap do |h|
        h.default_proc = -> _, k { "#{ k }s" }
        h.freeze
      end
    end
  end
end
