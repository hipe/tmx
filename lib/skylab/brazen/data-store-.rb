module Skylab::Brazen

  module Data_Store_

    class Actor
    private

      def via_action_init_action_properties
        init_action_properties_via @action
      end

      def via_entity_init_action_properties
        init_action_properties_via @entity
      end

      def init_action_properties_via o
        @dry_run = o.action_property_value :dry_run ; nil
      end

      def resolve_result_via_error_with * x_a, & p
        _ev = build_error_event_via_mutable_iambic_and_message_proc x_a, p
        resolve_result_via_error _ev
      end

      def resolve_result_via_error ev
        @result = listener.receive_error_event ev ; nil
      end

      def resolve_result_via_success_event ev
        @result = listener.receive_success_event ev ; nil
      end
    end

    class Model_ < Brazen_::Model_

      NAME_STOP_INDEX = 1  # sl brzn datastore actions couch add

    end

    class Action < Brazen_::Model_::Action

      NAME_STOP_INDEX = 1

    end
  end
end
