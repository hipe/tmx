module Skylab::Zerk

  class NonInteractiveCLI

    class When_Help_  # #[#sl-155]

      class Here_::Help_Frame_for_Compound___

        def initialize modality_frame, sess
          @_session = sess
          @_modality_frame = modality_frame
        end

        def step_

          @_upstream = @_session.upstream_

          if Begins_with_dash_[ @_upstream.current_token ]
            __step_for_option
          else
            __step_for_navigational
          end
        end

        def __step_for_navigational

          vf = @_session.parse_one_modality_frame_ :navigational, @_modality_frame
          if vf
            @_session.push_via_modality_frame_ vf
          else
            @_session.init_exitstatus_for_ :referent_not_found
            STOP_PARSING_
          end
        end

        def effect_help_screen_

          _vendor_help = Remote_when_[]::Help::For_Branch.new

          _ada = Vendor_Adapter___.new @_modality_frame, @_session.CLI_

          @_session.common_effect_help_screen_ _ada, _vendor_help

          NIL_
        end

        # ==

        class Vendor_Adapter___ < Vendor_Adapter_

          # -- usage section

          def write_syntax_strings_ y

            p = @CLI.compound_usage_strings
            if p
              _sa = Remote_CLI_lib_[]::Syntax_Assembly.for self
              p[ y, _sa ]
            else
              ___write_common_syntax_strings y
            end
          end

          def ___write_common_syntax_strings y

            head = subprogram_name_string

            _prp = properties.fetch :action

            me = self
            expression_agent.calculate do
              same = par _prp
              y << "#{ head } #{ same } #{ me.__named_args_part }"
              y << "#{ head } -h #{ same }"
            end
            y
          end

          def do_express_options_as_actions_for_help
            # (whether or not to treat options like actions, in the display)
            # (usually we do this IFF '--help' is the only option)
            true
          end

          # -- description section

          def express_custom_sections
            p = @CLI.compound_custom_sections
            if p
              p[ self ]
            end
          end

          def express_sections_by  # for above

            o = Remote_CLI_lib_[]::Section::DSL.new self
            yield o
            o.finish
          end

          # -- o.p

          def option_parser

            # 2x: first time: be something trueish with metrics or you don't
            # get to have 2-column layout (:#over-here).

            @modality_frame_.compound_option_parser__
          end

          # -- items section

          def to_adapter_stream

            # this is what the vendor help rendering agent will request to
            # get the items it expresses in its "actions" section.

            # this compound node wants the constituency of the items in this
            # section to be its [#030] navigational nodes.

            h = {
              association: Compound_as_Item___,
              operation: Operation_as_Item___,
            }

            @modality_frame_.to_navigational_node_ticket_stream_.map_by do |nt|
              h.fetch( nt.node_ticket_category ).new nt, @modality_frame_
            end
          end

          def wrap_adapter_stream_with_ordering_buffer st

            st  # adhere to [#033] - we do no additional ordering of items
          end

          # --

          def express_invite_to_help_as_compound_to me

            @CLI.express_stack_invite_ :as_compound_invite_to, me
            NIL_
          end

          # -- name & nearby

          def __named_args_part
            "[named args]"
          end

          # -- support

          def properties  # only to say '<action>'. sub-client and here
            Remote_CLI_lib_[].standard_branch_property_box
          end
        end

        # == adapt to [br] section rendering

        Item__ = ::Class.new

        class Compound_as_Item___ < Item__

          def initialize nt, frame
            @_formal_node = nt.association  # expect already built
            @modality_frame_ = frame
          end

          def description_proc  # nasty: watch:
            # you do *not* want the desc of `frame` -

            p = @_formal_node.description_proc
            if ! p and @_formal_node.component_model.method_defined? :describe_into_under
              p = ___build_crazy_desc_proc
            end
            @__last_desc_p = p
            p
          end

          def ___build_crazy_desc_proc  # :#this

            asc = @_formal_node
            fr = @modality_frame_
            -> y do
              _qk = fr.qualified_knownness_of_touched_via_association_ asc
              _qk.value_x.describe_into_under y, self
            end
          end

          def description_proc_for_summary_under _expag
            remove_instance_variable :@__last_desc_p
          end

          def name
            @_formal_node.name
          end
        end

        class Operation_as_Item___ < Item__

          def initialize nt, frame
            @_frame = frame
            @_node_ticket = nt
          end

          def description_proc_for_summary_under _expag

            # assume `description_proc` resulted in true-ish.
            # (we exercize this hook-in but currently don't leverage it
            # to do anything beyond what would happen without it.)

            dp = description_proc

            -> y do
              calculate y, & dp  # (hi.)
            end
          end

          def description_proc
            fo = _formal
            _p = fo.description_proc
            _p || fo.description_proc_thru_implementation
          end

          def _formal
            @___formal_op ||= ___build_formal_operation
          end

          def ___build_formal_operation
            @_frame.build_formal_operation_via_node_ticket_ @_node_ticket
          end

          def name
            @_node_ticket.name
          end
        end

        class Item__

          def is_visible
            true
          end
        end
        # ==
      end
    end
  end
end
