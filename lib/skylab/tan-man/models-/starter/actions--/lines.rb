module Skylab::TanMan

  class Models_::Starter

    module Actions__

      class Lines < Action_

        Entity_[ self,
          :required, :property, :value_fetcher,
          :properties,
          :use_default,
          :workspace, :workspace_path, :config_filename ]

        def produce_any_result
          if @argument_box[ :use_default ]
            via_default
          else
            via_workspace
          end
        end

        def via_default
        end

        def via_workspace
          bx = @argument_box
          ok = @kernel.call :starter, :get,
            :workspace, bx[ :workspace ],
            :workspace_path, bx[ :workspace_path ],
            :config_filename, bx[ :config_filename ],
            :event_receiver, self
          ok and via_entity
        end

        def receive_event ev
          if :entity == ev.terminal_channel_i
            @entity = ev.entity
            ACHIEVED_
          else
            @event_receiver.receive_event ev
          end
        end

        def via_entity
          @path = @entity.to_path
          via_path
        end

        def via_path
          @template = TanMan_::Lib_::String_lib[].template.from_path @path
          via_template
        end

        def via_template
          @output_s = @template.call @argument_box.fetch( :value_fetcher )
          via_output_s
        rescue ::Errno::ENOENT => e
          @enoent = e
          when_enoent
        end

        def when_enoent
          _ev = Lib_::Entity[].event.wrap.exception.with(
            :path_hack,
            :terminal_channel_i, :resource_not_found,
            :exception, @enoent )
          receive_event _ev
        end

        def via_output_s
          TanMan_::Lib_::String_IO[].new @output_s
        end
      end
    end
  end
end
