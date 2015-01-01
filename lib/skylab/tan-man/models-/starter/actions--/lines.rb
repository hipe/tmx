module Skylab::TanMan

  class Models_::Starter

    module Actions__

      class Lines < Action_

        Entity_.call self,

            :required, :property, :value_fetcher,

            :properties,
              :use_default,
              :workspace,
              :workspace_path,
              :config_filename

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
          @entity = @kernel.call :starter, :get,
            :workspace, bx[ :workspace ],
            :workspace_path, bx[ :workspace_path ],
            :config_filename, bx[ :config_filename ],
            :on_event_selectively, prdc_handle_payload
          @entity and via_entity
        end

        def prdc_handle_payload
          -> * i_a, & ev_p do
            if :payload == i_a.first
              ev_p[].to_event.entity
            else
              maybe_send_event_via_channel i_a, & ev_p
            end
          end
        end

        def via_entity
          @path = @entity.to_path
          via_path
        end

        def via_path
          @template = TanMan_.lib_.string_lib.template.via_path @path
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
          maybe_send_event :error, :resource_not_found do
            via_enoent_bld_event
          end
        end

        def via_enoent_bld_event
          LIB_.entity.event.wrap.exception.with(
            :path_hack,
            :terminal_channel_i, :resource_not_found,
            :exception, @enoent )
        end

        def via_output_s
          TanMan_.lib_.string_IO.new @output_s
        end
      end
    end
  end
end
