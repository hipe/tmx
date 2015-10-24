module Skylab::Cull

  class Models_::Survey

    Autoloader_[ Actions = ::Module.new, :boxxy ]

    # ~ begin stowaways

    class Actions::Ping < Action_

      def produce_result

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

      Common_entity_.call self,

        :flag, :property, :dry_run,

        :reuse, COMMON_PROPERTIES_,

        :description, -> y do
          y << "create a cull survey workspace directory in the path"
        end,
        :required, :property, :path


      def produce_result

        @bx = to_full_qualified_knownness_box

        @survey = Models_::Survey.edit_entity @kernel, handle_event_selectively do | edit |

          edit.create_via_mutable_qualified_knownness_box_and_look_path(
            @bx,
            @argument_box.fetch( :path ) )
        end

        @survey and via_survey
      end

      def via_survey
        Survey_::Actors__::Create[ @survey, @bx, & handle_event_selectively ] and
          when_created
      end

      def when_created
        maybe_send_event :info, :created_survey do
          @survey.to_event
        end
      end
    end
  end
end
