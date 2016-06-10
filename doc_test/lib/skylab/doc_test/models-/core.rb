module Skylab::DocTest

  module DocTest

    class Action_ < Brazen_::Action

      Brazen_::Modelesque.entity self do

      end
    end

    module Models_
      Autoloader_[ self, :boxxy ]  # detect constants thru filesystem
    end

    class Models_::Ping < Action_
      # ->

        def produce_result

          _event.maybe_send :payload, :ping do

            build_OK_event_with :ping do |y, o|
              y << "ping #{ highlight '!' }"
            end
          end

          :_hello_from_doc_test_
        end
      # -
    end
  end
end
