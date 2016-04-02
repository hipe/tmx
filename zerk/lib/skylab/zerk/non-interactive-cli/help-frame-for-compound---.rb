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
            @_session.init_exitstatus_for_ :_referent_not_found_
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

        class Vendor_Adapter___

          # (we want that a lot of this goes up to a shared base class, but it's too early yet)

          def initialize mf, cli
            @CLI = cli
            @modality_frame_ = mf
          end

          # -- usage section

          def express_usage_section
            express_section(
              :header, 'usage',
              :tight,
            ) do |y|
              ___write_syntax_strings y
            end  # result is whether or not did any output
            NIL_
          end

          def ___write_syntax_strings y

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

          def express_options_as_actions_for_help
            # (whether or not to treat options like actions, in the display)
            # (usually we do this IFF '--help' is the only option)
            true
          end

          # -- description section

          def express_description
            p = @modality_frame_.description_proc_
            if p
              ___expresss_this_description p
            end
          end

          def ___expresss_this_description p

            express_section(
              :header, 'description',
              :tight,
            ) do |y|
              expression_agent.calculate y, & p
            end  # result is whether or not did any
            NIL_
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

          # -- name & nearby

          def __named_args_part
            "[named args]"
          end

          def subprogram_name_string
            @___sns ||= ___build_subprogram_name_string
          end

          def ___build_subprogram_name_string

            st = @modality_frame_.to_frame_stream_from_bottom__

            s = st.gets.get_program_name_string__

            begin
              fr = st.gets
              fr or break
              s << SPACE_
              s << fr.subprogram_name_slug_
              redo
            end while nil

            s
          end

          # -- support

          def express_section * x_a, & p  # by [br] sub-client and here
            _ = @CLI.express_section_via__ x_a, & p
            _  # whether or not it did some
          end

          def expression_agent
            @CLI.expression_agent
          end

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

          def initialize nt, _frame
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
            @_node_ticket.formal.description_proc
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
