module Skylab::Brazen

  class Data_Stores::Couch

    class Actors__::Delete_datastore < Couch_Actor_

      Actor_.call self, :properties,
        :dry_run_arg,
        :force_arg,
        :entity,
        :remote

      def execute
        init_ivars
        _ok = check_force
        _ok && work
      end

    private

      def init_ivars
        @datastore_s = @entity.property_value_via_symbol :name
        init_response_receiver_for_self_on_channel :delete_datastore
        nil
      end

      def check_force
        if @force_arg.value_x
          PROCEDE_
        else
          when_force_not_present
        end
      end

      def when_force_not_present
        maybe_send_event :error, :missing_force do
          bld_missing_force_event
        end
        UNABLE_
      end

      def bld_missing_force_event
        build_not_OK_event_with :missing_force, :prop, @force_arg.property do |y, o|
          y << "missing required #{ par o.prop }"
        end
      end

      def work
        if @dry_run_arg.value_x
          delete_datastore_when_dry_run
          PROCEDE_
        else
          x_a = []
          x_a.push :entity_identifier_strategy, :__N_O_N_E__
          x_a.push :response_receiver, @response_receiver
          @remote.delete x_a
        end
      end

    public

      def delete_datastore_when_dry_run
        maybe_send_event :info, :pretending_for_dry_run do
          build_OK_event_with :pretending_for_dry_run, :pretending, :pretending
        end ; nil
      end

      def delete_datastore_when_200_ok o
        maybe_send_event :info, :removed do
          o.response_body_to_completion_event :name, @datastore_s do |y, ev|
            y << "#{ ev.message } - removed datastore #{ val ev.name }"
          end
        end ; nil
      end

      def delete_datastore_when_404_object_not_found o
        maybe_send_event :error, :not_found do
          o.response_body_to_not_OK_event
        end ; nil
      end
    end
  end
end
