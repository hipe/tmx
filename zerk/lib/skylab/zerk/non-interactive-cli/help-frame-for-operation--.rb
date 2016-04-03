module Skylab::Zerk

  class NonInteractiveCLI

    class When_Help_  # #[#sl-155]

      class Here_::Help_Frame_for_Operation__

        def initialize modality_frame, sess
          @_session = sess
          @_modality_frame = modality_frame
        end

        def step_

          @_upstream = @_session.upstream_
          @_token = @_upstream.current_token

          if Begins_with_dash_[ @_token ]
            __step_for_option
          else
            ___dead_end_at_other_navigational
          end
        end

        def ___dead_end_at_other_navigational

          tok = @_token
          moniker = @_modality_frame.subprogram_name_string_

          @_session.handle_ :error, :expression do |y|
            y << "#{ val moniker } is an action. actions never have children."
            y << "as such it is meaningless to request for help on #{
              }#{ ick tok } here."
          end

          @_session.init_exitstatus_for_ :_referent_not_found_

          STOP_PARSING_
        end

        def effect_help_screen_

          _vendor_help = Remote_when_[]::Help::For_Action.new

          _ada = Vendor_Adapter___.new @_modality_frame, @_session.CLI_

          @_session.common_effect_help_screen_ _ada, _vendor_help

          NIL_
        end

        # ==

        class Vendor_Adapter___ < Vendor_Adapter_

          # -- usage section

          def write_syntax_strings_ y

            head = subprogram_name_string

            Here_.option_parser_WIP_
            _args = " «NAMED ARGS PLACEHOLDER»"

            expression_agent.calculate do
              y << "#{ head }#{ _args }"
              y << "#{ head } -h <named-arg>"
            end
            y
          end

          # -- o.p

          def option_parser
            Here_.option_parser_WIP_
            NOTHING_
          end

          # -- items section

          def express_options_as_actions_for_help
            false
          end

          # -- ad-hoc sections

          def to_section_stream
            NOTHING_  # but if you wanted to we could..
          end
        end
      end
    end
  end
end
