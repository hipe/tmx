module Skylab::Snag

  module Model_

    Info_Error_Listener = Callback_::Ordered_Dictionary.new :info, :error

    THROWING_INFO_ERROR_LISTENER = Info_Error_Listener.new nil, -> ev do
      raise ev.render_under_expression_agent Snag_::API::EXPRESSION_AGENT
    end

    class Event < ::Struct

      Snag_::Lib_::Model_event[ self ]

      EVENTS_ANCHOR_MODULE = Snag_::Models

      class << self
        def message_proc & p
          define_method :message_proc do
            p
          end
        end
      end

      include module Event_Instance_Methods__

        def is_event  # :+#comport
          true
        end

        def can_render_under  # :+#comport
          !! message_proc
        end

        attr_reader :message_proc

        def render_under client
          render_under_expression_agent client.expression_agent
        end

        def render_under_expression_agent expression_agent
          y = []
          expression_agent.calculate y, self, & message_proc
          y * LINE_SEP_
        end

        self
      end

      def self.inline * x_a, & p
        Inline__.new x_a, p
      end
      class Inline__
        include Event_Instance_Methods__
        def initialize x_a, p
          @message_proc = p
          @terminal_channel_i = x_a.fetch 0
          d = -1 ; last = x_a.length - 2 ; sc = singleton_class
          while d < last
            d += 2 ; i = x_a.fetch d
            sc.send :attr_reader, i
            instance_variable_set :"@#{ i }", x_a.fetch( d + 1 )
          end ; nil
        end
        attr_reader :terminal_channel_i
      end
    end
  end
end
