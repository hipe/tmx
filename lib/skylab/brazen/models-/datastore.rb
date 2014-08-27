module Skylab::Brazen

  class Models_::Datastore < Brazen_::Model_

    class << self
      def build_collections kernel
        Collections__.new kernel
      end
    end

    Brazen_::Model_::Entity[ self, -> do
      o :desc, -> y do
        y << "manage datastores."
      end
    end ]

    class << self
      def get_unbound_upper_action_scan
        fresh = true
        Entity_[].scan.new do
          if fresh
            fresh = false
            r = self
          end
          r
        end
      end
    end

    def get_lower_action_scan
      mod = Brazen_::Data_Stores_
      i_a = mod.constants ; d = -1 ; last = i_a.length - 1
      Entity_[].scan do
        if d < last
          _cls = mod.const_get i_a.fetch d += 1
          _cls.new @kernel
        end
      end
    end

    class Collections__
      def initialize kernel
        @kernel = kernel
      end

      def name_i
        :datastore
      end
    end
  end
end
