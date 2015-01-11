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

        def via_workspace

          bx = @argument_box

          @starter = @kernel.call :starter, :get,
            :workspace, bx[ :workspace ],
            :workspace_path, bx[ :workspace_path ],
            :config_filename, bx[ :config_filename ],
            & @on_event_selectively

          @starter and via_starter
        end

        def via_default
          @st = @kernel.call :starter, :ls, & @on_event_selectively
          @st and via_starter_stream
        end

        def via_starter_stream
          x = @st.gets
          count = 0
          while x
            count += 1
            last = x
            x = @st.gets
          end

          if last
            maybe_send_using_default last, count
            @starter = last
            via_starter
          else
            self._NEVER
          end
        end

        def maybe_send_using_default strtr, d
          maybe_send_event :info, :using_default do
            bld_using_default_event strtr, d
          end
        end

        def bld_using_default_event strtr, d

          build_neutral_event_with :using_default,
              :name_s, strtr.local_entity_identifier_string,
              :num, d do |y, o|

            y << "using default starter #{ val o.name_s } #{
             }(the last of #{ o.num } starter#{ s o.num })"
          end
        end

        def via_starter
          @path = @starter.to_path
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
