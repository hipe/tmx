module Skylab::Basic

  module Mutex  # ~ stowaway

    class << self

      def hash
        Hash__
      end

      def write_once
        Mutex_::Write_Once__
      end
    end

  class Hash__

    def initialize &blk
      @h = { }
      @collision_proc = blk || -> k, currently_held_by_x, hold_requested_by_x do
        raise "#{ hold_requested_by_x } cannot also #{ k } while it is #{
          }begin done by #{ currently_held_by_x }"
      end
    end

    def hold_notify k_x, by_x
      did = false
      holding = @h.fetch k_x do |_|
        did = true
        @h[ k_x ] = by_x
        nil
      end
      did or @collision_proc[ k_x, holding, by_x ]
    end
  end

    Mutex_ = self
  end
end
