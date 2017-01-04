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

          @_session.init_exitstatus_for_ :referent_not_found

          STOP_PARSING_
        end

        def effect_help_screen_

          _vendor_help = Here_::Help::For_Action.new

          _ada = Vendor_Adapter___.new @_modality_frame, @_session.CLI_

          @_session.common_effect_help_screen_ _ada, _vendor_help

          NIL_
        end

        # ==

        class Vendor_Adapter___ < Vendor_Adapter_

          # -- usage section

          def write_syntax_strings_ y

            # write lines. (each `<<` sends one line.) we write only one
            # line. (to write a second line explaing help is redundant
            # because such an explanation appears in the options section.)

            sa = Remote_CLI_lib_[]::Syntax_Assembly.for self

            p = @CLI.operation_usage_string
            if p
              s = p[ sa ]
            else
              s = sa.express_main_syntax_string_didactically_into ""
            end
            if s
              y << s
            end
            y
          end

          # -- args (for syntax)

          def didactic_argument_properties
            @modality_frame_.operation_syntax_.any_argument_attributes_array__
          end

          # --

          def express_custom_sections
            NOTHING_  # (we haven't wanted these yet)
          end

          # -- o.p

          def option_parser
            @modality_frame_.operation_syntax_.option_parser__
          end

          # -- items section

          def do_express_options_as_actions_for_help
            false
          end

          # -- ad-hoc sections

          def custom_sections & p  # [#061.2]

            @modality_frame_.operation_syntax_.custom_section__( & p )
          end
        end
      end
    end
  end
end
