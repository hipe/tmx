module Skylab::Snag

  Model_ = ::Module.new


  class Model_::Event < ::Struct

    Snag_::Lib_::Model_event[ self ]

    EVENTS_ANCHOR_MODULE = Snag_::Models

    def self.normalized_event_name
      @nen ||= begin              # (just for fun chop out the `events`
        arr = super.dup           # box module, for aesthetics and to see
        arr[1, 1] = []            # what happens.)
        arr
      end
    end

    class << self
      def message_proc & p
        define_method :message_proc do
          p
        end
      end
    end

    def is_event  # :+#comport
      true
    end

    def can_render_under  # :+#comport
      !! message_proc
    end

    def render_under client
      _expag = client.expression_agent
      y = []
      _expag.calculate y, self, & message_proc
      y * LINE_SEP_
    end

    def message_proc
    end
  end
end
