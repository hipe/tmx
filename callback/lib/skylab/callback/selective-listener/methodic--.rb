module Skylab::Callback

  module Selective_Listener

    class Methodic__  # :[#013]. quite similar to [#006]

      Attributes_actor_.call( self,
        delegate: nil,
        prefix: nil,
      )

      def initialize
        @delegate = nil
        @prefix = nil
        self._K
        super
        nilify_uninitialized_ivars
      end

      def handle_event_selectively
        @HES_p ||= method :maybe_receive_event
      end

      def maybe_receive_event * routing_i_a, & build_event_p
        chain = build_chain routing_i_a
        _some_is_subscribed_to_method  = some_is_subscribed_to_method chain
        _is_subscribed = @delegate.send _some_is_subscribed_to_method
        if _is_subscribed
          _receive_method = some_receive_method chain
          _ev = build_event_p.call
          @delegate.send _receive_method, _ev
        end
      end

    private

      def build_chain routing_i_a
        memo = if @prefix
          [ @prefix ]
        else
          []
        end
        chain = []
        routing_i_a.each do |i|
          memo.push i
          chain.push memo.dup
        end
        memo = nil
        chain
      end

      def some_is_subscribed_to_method chain
        is_method = nil
        ( chain.length - 1 ).downto( 1 ).detect do |d|
          m_i = :"is_subscribed_to_#{ chain.fetch( d ) * UNDERSCORE_ }"
          if @delegate.respond_to? m_i
            is_method = m_i
            break
          end
        end
        is_method || :"is_subscribed_to_#{ chain.fetch( 0 ) * UNDERSCORE_ }"
      end

      def some_receive_method chain
        method = nil
        ( chain.length - 1 ).downto( 1 ).detect do |d|
          m_i = :"receive_#{ chain.fetch( d ) * UNDERSCORE_ }"
          if @delegate.respond_to? m_i
            method = m_i
            break
          end
        end
        method || :"receive_#{ chain.fetch( 0 ) * UNDERSCORE_ }"
      end
    end
  end
end
