module Skylab::Brazen

  class Data_Stores_::Couch

    class Actors__::Delete_datastore < Couch_Actor_

      Actor_[ self, :properties,
        :action, :kernel ]

      def execute
        via_action_init_action_properties
        @result = nil
        @datastore_i = @action.action_property_value :name
        ok = via_datastore_name_resolve_datastore
        ok &&= via_datastore_resolve_result
        Actors__::Delete_datastore_entity__[ @action, @kernel ]
        @result
      end

    private

      def via_datastore_resolve_result
        if @action.action_property_value :force
          @datastore.delete_datastore self, :delete_datastore, self
        else
          resolve_result_when_force_not_present
        end
      end

    public

      def delete_datastore_when_dry_run _
        @action.receive_success_event build_event( :pretend, :pretending, :pretending )
        @result = nil
      end

      def delete_datastore_when_200_ok o
        _ev = o.response_body_to_completion_event :name, @datastore_i do |y, ev|
          y << "#{ ev.message } - removed datastore #{ val ev.name }"
        end
        @result = @action.receive_success_event _ev ; nil
      end

      def delete_datastore_when_404_object_not_found o
        _ev = o.response_body_to_error_event
        @result = @action.receive_error_event _ev ; nil
      end

    private

      def resolve_result_when_force_not_present
        force = @action.class.properties.fetch :force
        _ev = build_event :missing_force, :is_positive, false do |y, o|
          y << "missing required #{ par force }"
        end
        @result = listener.receive_error_event _ev ; nil
      end

      def listener
        @action
      end
    end
  end
end
