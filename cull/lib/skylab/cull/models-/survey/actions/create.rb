module Skylab::Cull

  class Models_::Survey

    # ~ begin stowaways

    class Actions::Ping < Action_

      def produce_result

        @on_event_selectively.call :info, :ping do
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

      Common_entity_.call( self,

        :flag, :property, :dry_run,

        :reuse, COMMON_PROPERTIES_,

        :description, -> y do
          y << "create a cull survey workspace directory in the path"
        end,
        :required, :property, :path,
      )

      def produce_result

        @bx = to_full_qualified_knownness_box

        x = Models_::Survey.edit_entity @kernel, @on_event_selectively do | edit |

          edit.create_via_mutable_qualified_knownness_box_and_look_path(
            @bx,
            @argument_box.fetch( :path ) )
        end

        if x
          @_survey = x
          ___via_survey
        else
          x
        end
      end

      def ___via_survey

        ok = Here_::Actors__::Create[ @_survey, @bx, & @on_event_selectively ]
        if ok

          Common_::Emission.of :info, :created_survey do
            @_survey.to_event
          end

        else
          ok
        end
      end
    end
  end
end
