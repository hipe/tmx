module Skylab::TanMan

  class Model_

    class Document_Entity < self

      class Collections_Controller < Brazen_.model.collections_controller

        def initialize( * )
          @sub_p = nil
          super
        end

        def persist_entity e
          @entity = e
          ok = via_entity_resolve_collection_controller
          ok and @collection_controller.persist_entity @entity
        end

        def build_collection_controller_with * x_a
          i_a = [] ; a = [] ; x_a.each_slice 2 do |i, x|
            i_a.push i ; a.push x
          end
          send :"build_collection_controller_via_#{ i_a * '_and_' }", * a
        end

        def on_parsing_events_subscription p
          @sub_p = p ; nil
        end

      private

        def via_entity_resolve_collection_controller
          ok = via_entity_resolve_datastore_controller
          ok and via_datastore_controller_resolve_collection_controller
        end

        def build_collection_controller_via_input_pathname pn
          ok = resolve_datastore_controller_via_pathname pn
          ok &&= via_datastore_controller_resolve_collection_controller
          ok and @collection_controller
        end

        def resolve_datastore_controller_via_pathname pn
          @datastore_controller =
            other_collections.resolve_datastore_controller_with(
              :parsing_event_subscription, @sub_p,
              :input_pathname, pn, :channel, @channel, :delegate, @delegate )
          @datastore_controller ? ACHEIVED_ : UNABLE_
        end

        def via_entity_resolve_datastore_controller
          @datastore_controller = other_collections.
            resolve_datastore_controller_via_entity @entity,
              :parsing_event_subscription, @sub_p
          @datastore_controller ? ACHEIVED_ : UNABLE_
        end

        def via_datastore_controller_resolve_collection_controller
          @collection_controller = collections.
            build_collection_controller_with(
              :datastore_controller, @datastore_controller )
          @collection_controller ? ACHEIVED_ : UNABLE_
        end

        def collections
          @collections ||= @kernel.models[
            @model_class.name_function.as_lowercase_with_underscores_symbol ]
        end

        def other_collections
          @kernel.models[ :dot_file ]
        end
      end

      class Collection_Controller

        class << self

          def build_via_iambic x_a
            o = new do
              init_via_iambic x_a
            end
            o.valid_self
          end
        end

        def initialize & p
          instance_exec( & p )
        end

        def unparse_entire_document
          @datastore_controller.unparse_entire_document
        end

      private
        def init_via_iambic x_a
          i_a = [] ; a = []
          x_a.each_slice 2 do |i, x|
            i_a.push i ; a.push x
          end
          send :"init_via_#{ i_a * '_and_' }", * a
        end

        def init_via_datastore_controller_and_kernel * a
          @datastore_controller, @kernel = a
          @channel, @delegate = @datastore_controller.channel_and_delegate
        end

        def maybe_persist
          @datastore_controller.maybe_persist
        end
      public
        def valid_self
          self
        end
      end
    end
  end
end
