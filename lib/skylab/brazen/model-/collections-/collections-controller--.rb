module Skylab::Brazen

  class Model_

    class Collections_

      class Collections_Controller__

        include Entity_[]::Event::Builder_Methods

        def initialize * a
          @channel, @delegate, @model_class, @kernel = a
          @did_rslv_cc = false
        end

        def produce_collection_controller
          @did_rslv_cc or rslv_cc
          @cc
        end

      private

        def rslv_cc
          @did_rslv_cc = true
          @persist_to = @model_class.persist_to
          if @persist_to
            via_persist_to_rslv_cc
          else
            @cc = when_no_persist_to
          end ; nil
        end

        def when_no_persist_to
          send_error_with :persist_to_not_set, :model_class, @model_class do |y, o|
            y << "`persist_to` is not set for #{ o.model_class }"
          end
          UNABLE_
        end

        def via_persist_to_rslv_cc
          @datastore_model_i, @datastore_i = @persist_to.to_s.
            split( UNDERSCORE_, 2 ).map( & :intern )
          ok = via_datastore_model_name_rslv_datastore_collections
          ok && via_datastore_collections_resolve_collection_controller
        end

        def via_datastore_model_name_rslv_datastore_collections
          ok = ACHEIVED_ ; @datastore_collections =
          @kernel.datastores.retrieve_by_name @datastore_model_i, -> ev do
            send_error ev ; ok = UNABLE_
          end
          ok
        end

        def via_datastore_collections_resolve_collection_controller
          @cc = @datastore_collections.build_collection_controller(
            @datastore_i, :the_collection, @delegate, @model_class, @kernel )
          ACHEIVED_
        end

        def send_error_with * x_a, & p
          _ev = build_error_event_via_mutable_iambic_and_message_proc x_a, p
          send_error _ev
        end

        def send_error ev
          @delegate.send :"receive_#{ @channel }_error", ev
        end
      end
    end
  end
end
