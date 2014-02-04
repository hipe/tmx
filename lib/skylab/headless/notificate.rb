module Skylab::Headless

  module Notificate  # #todo:during:merge  not used yet
    def self.[] mod
      mod.extend MM__ ; mod.send :include, IM__ ; nil
    end
    module MM__
      attr_reader :notificiation_listener_p_a_h
    private
      def add_notification_listener event_i, & subroutine_p
        ( @notificiation_listener_p_a_h ||= { } ).fetch event_i do
          @notificiation_listener_p_a_h[ event_i ] = [ ]
        end.push subroutine_p ; nil
      end
    end
    module IM__
    private
      def notificate i
        h = self.class.notificiation_listener_p_a_h
        if h
          p_a = h[ i ]
          if p_a
            p_a.each do |p|
              instance_exec( & p )
            end
          end
        end
        super
      end
    end
  end
end:w

