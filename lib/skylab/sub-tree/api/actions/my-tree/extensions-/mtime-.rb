module Skylab::SubTree

  class API::Actions::My_Tree

    class Extensions_::Mtime_

      IT_ = SubTree::Services::InformationTactics

      MetaHell::FUN::Fields_[ :client, self, :method, :absorb, :field_i_a,
        [ :local_normal_name, :infostream, :verbose ] ]

      def initialize *a
        @now_t = SubTree::Services::Time.new  # doesn't get cleared anywhere
        absorb( *a )
        nil
      end

      attr_reader :local_normal_name

      def is_post_notifiee
        false
      end

      def in_notify leaf
        stat = ::File::Stat.new leaf.input_line  # move into leaf if optimal
        seconds_old = @now_t - stat.mtime
        unit_i, amt_f = IT_::Summarize::Time[ seconds_old ]
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
