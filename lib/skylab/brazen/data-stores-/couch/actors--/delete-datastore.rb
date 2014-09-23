module Skylab::Brazen

  class Data_Stores_::Couch

    class Actors__::Delete_datastore < Couch_Actor_

      Actor_[ self, :properties,
        :entity,
        :props,
        :remote,
        :event_receiver ]

      def execute
        init_ivars
        ok = check_force
        ok && work
      end

    private

      def init_ivars
        @dry_run = @entity.any_parameter_value :dry_run
        @has_force = @entity.any_parameter_value :force
        @datastore_s = @entity.property_value :name
        init_response_receiver_for_self_on_channel :delete_datastore
        nil
      end

      def check_force
        if @has_force
          PROCEDE_
        else
          when_force_not_present
        end
      end

      def when_force_not_present
        _ev = bld_missing_force_event
        send_event _ev
        UNABLE_
      end

      def bld_missing_force_event
        _FORCE_ = @props.fetch :force
        build_not_OK_event_with :missing_force do |y, o|
           y << "missing required #{ par _FORCE_ }"
        end
      end

      def work
        if @dry_run
          delete_datastore_when_dry_run nil
          PROCEDE_
        else
          x_a = []
          x_a.push :entity_identifier_strategy, :__N_O_N_E__
          x_a.push :response_receiver, @response_receiver
          @remote.delete x_a
        end
      end

    public

      def delete_datastore_when_dry_run _
        _ev = build_OK_event_with( :pretending_for_dry_run, :pretending, :pretending )
        send_event _ev
        nil
      end

      def delete_datastore_when_200_ok o
        _ev = o.response_body_to_completion_event :name, @datastore_s do |y, ev|
          y << "#{ ev.message } - removed datastore #{ val ev.name }"
        end
        send_event _ev ; nil
      end

      def delete_datastore_when_404_object_not_found o
        _ev = o.response_body_to_not_OK_event
        send_event _ev ; nil
      end
    end
  end
end
