module Skylab::Cull

  class Models_::Survey

    # ~ begin stowaways

    Autoloader_[ ( Actions = ::Module.new ), :boxxy ]

    Actions::Ping = -> call do

      call.maybe_receive_event :info, :ping do

        Brazen_.event.wrap.signature(
          call.action_class_like.name_function,
          ( Brazen_.event.inline_neutral_with :ping do | y, o |
            y << "hello from #{ call.kernel.app_name }."
          end ) )
      end

      :hello_from_cull
    end

    class Actions::Ping2 < Action_

      # we have the odd situation of wanting to use the same name
      # twice: one for the promoted action and once for this one.

      @name_function = Brazen_.model.action_class.name_function_class.new(
        self, Actions, :Ping )

      def produce_any_result

        maybe_send_event :info, :ping do
          app_name = @kernel.app_name
          build_OK_event_with :ping do | y, o |
            y << "#{ app_name } says #{ highlight 'hello' }"
          end
        end

        :_hi_again_
      end
    end

    # ~ end stowaways

    class Actions::Create < Action_

      @is_promoted = true

      @after_name_symbol = :ping

      Brazen_.model.entity self,

        :flag, :property, :dry_run,

        :required,
        :description, -> y do
          y << "create a cull survey workspace directory in the path"
        end,
        :property, :path


      def produce_any_result

        @ent = Models_::Survey.edit_entity @kernel, handle_event_selectively do | o |

          o.create_via_mutable_bound_argument_box to_bound_argument_box
        end

        @ent and via_ent
      end

      def via_ent
        maybe_send_event :info, :created_survey do
          @ent.to_event
        end
      end
    end
  end
end
