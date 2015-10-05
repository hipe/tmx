module Skylab::Brazen

  class Models_::Collection < Home_::Model

    edit_entity_class(

      :desc, -> y do
        y << "manage collections."
      end,

      :after, :workspace )

    class << self

      def to_upper_unbound_action_stream
        Callback_::Stream.via_item self
      end

      def init_action_class_reflection_
        @acr = Home_::Model::Child_Node_Index.new self, Home_::Collection_Adapters
        true
      end
    end  # >>

    Silo_Daemon = nil
  end
end
