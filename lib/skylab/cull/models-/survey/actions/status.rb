module Skylab::Cull

  class Models_::Survey

    class Actions::Status < Action_

      Brazen_.model.entity self,

        :after, :create,

        :desc, -> y do
          y << "display status of the survey"
        end,

        :description, -> y do
          y << "path from which the survey is searched for"
        end,
        :required, :property, :path

      def produce_any_result

        @path = Models_::Survey.any_nearest_path_via_looking_upwards_from_path(
          get_argument_via_property_symbol( :path ),
          & ___custom_listener )

        @path and via_path
      end

      def ___custom_listener
        -> * i_a, & ev_p do
          m = :"receive_#{ i_a.reverse.join UNDERSCORE_ }"
          if respond_to? m
            send m, ev_p[]
          else
            handle_event_selectively_via_channel.call i_a, & ev_p
          end
        end
      end

      def receive_xyz_event ev
      end

      UNDERSCORE_ = '_'.freeze
    end
  end
end
