module Skylab::TanMan

  class Models_::Starter

    module Actions__

      class Lines < Action_

        o = Models_::Workspace.common_properties

        edit_entity_class(

          :preconditions, EMPTY_A_,

          :flag, :property, :use_default,

          # reading from the workspace is an option, but the workspace is not a precondition

          :property_object, o[ :max_num_dirs ],
          :property_object, o[ :config_filename ],
          :property_object, o[ :workspace_path ].dup.set_is_not_required.freeze )

        def produce_result
          Session.new @kernel, handle_event_selectively do | o |
            o.trio_box = to_trio_box_proxy
          end.via_trio_box
        end

        class << self

          def via__ value_fetcher, starter, k, & oes_p
            Session.new k, oes_p do | o |
              o.starter = starter
              o.value_fetcher = value_fetcher
            end.via_starter
          end
        end

        # we cleaved an API action into an internal API

      class Session

        Callback_::Event.selective_builder_sender_receiver self

        def initialize k, oes_p
          @trio_box = nil
          @kernel = k
          @on_event_selectively = oes_p
          @value_fetcher = nil
          yield self
        end

        attr_writer :starter, :trio_box, :value_fetcher

        def via_trio_box
          if @trio_box[ :use_default ] && @trio_box[ :use_default ].value_x
            via_default
          else
            via_workspace_related_arguments
          end
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
          @on_event_selectively.call :info, :using_default do
            bld_using_default_event strtr, d
          end
        end

        def bld_using_default_event strtr, d

          build_neutral_event_with :using_default,
              :name_s, strtr.natural_key_string,
              :num, d do |y, o|

            y << "using default starter #{ val o.name_s } #{
             }(the last of #{ o.num } starter#{ s o.num })"
          end
        end

        def via_workspace_related_arguments

          @ws = @kernel.silo( :workspace ).workspace_via_trio_box(
            @trio_box, & handle_event_selectively )

          @ws and via_workspace
        end

        def via_workspace
          @starter = @kernel.silo( :starter ).starter_in_workspace( @ws, & @on_event_selectively )
          @starter and via_starter
        end

        def via_starter
          @template = TanMan_.lib_.string_lib.template.via_path @starter.to_path

          if ! @value_fetcher
            @value_fetcher = Mocking_Fetcher___.new
          end

          @output_s, @enoent = call_template
          if @output_s
            via_output_s
          else
            when_enoent
          end
        end

        def call_template
          @template.call @value_fetcher
        rescue ::Errno::ENOENT => e
          [ false, e ]
        end

        def when_enoent
          @on_event_selectively.call :error, :resource_not_found do
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

        class Mocking_Fetcher___

          def fetch sym

            "{{ #{ Callback_::Name.via_variegated_symbol( sym ).
              as_lowercase_with_underscores_symbol.id2name.upcase } }}"

          end
        end
      end
      end
    end
  end
end
