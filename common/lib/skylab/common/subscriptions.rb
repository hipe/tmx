module Skylab::Common

  class Subscriptions  # see [#043]

    class << self

      alias_method :orig_new, :new

      def new * i_a

        ::Class.new( self ).class_exec do

          class << self

            alias_method :new, :orig_new

          end

          # use [#ca-028] name conventions

          const_set :CHANNEL_A__, ( i_a.map do |i|

            chan = Channel__.new i

            define_method :"subscribe_to_#{ i }" do
              add_subscription chan
            end

            define_method :"on_#{ i }" do | &p |
              add_callback_proc p, chan
            end

            define_method :"unsubscribe_to_#{ i }" do
              remove_subscription chan
            end

            define_method :"is_subscribed_to_#{ i }" do
              is_subscribed chan
            end

            define_method :"handle_#{ i }" do
              produce_proc chan
            end

            define_method :"receive_#{ i }" do |ev|
              send_event_on_chan ev, chan
            end

            chan
          end )

          self
        end
      end
    end

    class Channel__
      def initialize i
        @name_symbol = i
        freeze
      end
      attr_reader :name_symbol
    end

    def initialize
      @do_use_subscription_channel_name = false
      @channel_i = nil
      @is_h = {} ; @p_h = {}
    end

    def delegate_to x
      @delegate = x ; nil
    end

    def delegate_to_selectively oes_p
      @delegate = Event_Receiver___.new do |ev|
        oes_p.call do
          ev
        end
      end
    end

    def use_channel_name_in_receiver_method_name i
      @channel_i = i
    end

    def subscribe_all
      scan = chan_scan
      while chan = scan.gets
        @is_h[ chan.name_symbol ] = true
      end ; nil
    end

    def unsubscribe_all
      scan = chan_scan
      while chan = scan.gets
        @is_h.delete chan.name_symbol
      end ; nil
    end

    def use_subscription_channel_name_in_receiver_method_name
      @do_use_subscription_channel_name = true ; nil
    end

  private

    def add_subscription chan
      @is_h[ chan.name_symbol ] = true
    end

    def add_callback_proc p, chan
      @is_h[ chan.name_symbol ] = true
      @p_h[ chan.name_symbol ] = p ; nil
    end

    def remove_subscription chan
      @is_h.delete chan.name_symbol
    end

    def is_subscribed chan
      @is_h.key? chan.name_symbol
    end

    def produce_proc chan
      -> ev do
        send_event_on_chan ev, chan
      end
    end

    def send_event_on_chan ev, chan
      if p = @p_h[ chan.name_symbol ]
        p[ ev ]
      else
        a = [ :receive ]
        if @channel_i
          a.push @channel_i
        end
        if @do_use_subscription_channel_name
          a.push chan.name_symbol
        else
          a.push :event
        end
        m_i = a * UNDERSCORE_
        if @delegate.respond_to? m_i
          @delegate.send m_i, ev
        else
          @delegate.receive_event ev
        end
      end
    end

    def chan_scan
      Home_::Stream.via_nonsparse_array self.class::CHANNEL_A__
    end

    class Event_Receiver___ < ::Proc
      alias_method :receive_event, :call
    end
  end
end
