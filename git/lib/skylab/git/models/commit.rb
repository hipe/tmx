module Skylab::Git

  module Models::Commit

    class Simple

      # (we were expecting maybe to cram some shared string view logic in here)

      def initialize sha, date, time, zone
        @date_string = date
        @sha_string = sha
        @time_string = time
        @zone_string = zone
      end

      attr_reader(
        :date_string,
        :sha_string,
        :time_string,
        :zone_string,
      )
    end
  end
end
# #history: abstracted from one-off
