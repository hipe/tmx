module Skylab::SubTree

  module API

    module Home_::Models_::Files

      class Extensions_::Mtime

        def initialize trio, & _
          @now_t = Home_::Library_::Time.new  # doesn't get cleared anywhere
          @trio = trio
        end

        def is_collection_operation
          false
        end

        def local_normal_name
          @trio.name_symbol
        end

        def receive_inline_mutable_leaf leaf

          stat = ::File::Stat.new leaf.input_line
            # (consider memoizing stat in leaf if ever optimal)

          seconds_old = @now_t - stat.mtime

          unit_i, amt_f = Home_.lib_.human::Summarize::Time[ seconds_old ]

          leaf.add_subcel "#{ amt_f.round } #{ ABBR_H_[ unit_i ] }"

          ACHIEVED_
        end

        # <-

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


      # ->

      end
    end
  end
end
