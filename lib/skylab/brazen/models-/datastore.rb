module Skylab::Brazen

  class Models_::Datastore < Brazen_::Model_

    Brazen_::Model_::Entity[ self, -> do
      o :desc, -> y do
        y << "manage datastores."
      end
    end ]

    class << self
      def get_upper_action_scan
        fresh = true
        Brazen_::Entity.scan.new do
          if fresh
            fresh = false
            r = new
          end
          r
        end
      end
    end

    def get_lower_action_scan
      mod = Brazen_::Data_Stores_
      i_a = mod.constants ; d = -1 ; last = i_a.length - 1
      Brazen_::Entity.scan do
        if d < last
          _cls = mod.const_get i_a.fetch d += 1
          _cls.new
        end
      end
    end
  end
end
