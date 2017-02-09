module Skylab::TestSupport

  module Quickie

    class Plugins::Help

      # -

        def initialize
          microservice = yield
          @lazy_index = microservice.lazy_index
          @listener = microservice.listener
          @operator_branch = microservice.operator_branch
        end

        def description_proc
          -> y { y << "this screen" }
        end

        def parse_argument_scanner_head
          # (scanner is already advanced past activating token
          ACHIEVED_
        end

        def release_agent_profile
          Eventpoint_::AgentProfile.define do |o|
            o.must_transition_from_to :beginning, :finished
          end
        end

        def invoke _
          if __resolve_resources
            __express_screen
          end
        end

        def __express_screen

          Zerk_::NonInteractiveCLI::Help::ScreenForBranch.express_into @stderr do |o|

            o.item_normal_tuple_stream __item_normal_tuple_stream

            o.express_usage_section __program_name

            o.express_description_section __description_proc

            o.express_items_sections __description_reader
          end
          # (result of above is NIL)

          NOTHING_
        end

        def __item_normal_tuple_stream
          @operator_branch.to_load_ticket_stream.map_by do |sym|
            [ :primary, sym ]
          end
        end

        def __description_reader
          -> k do
            _asset_ticket = @operator_branch.dereference k
            _ = @lazy_index.dereference_plugin_via_user_value _asset_ticket
            _wow = _.description_proc
            _wow  # #todo
          end
        end

        def __description_proc
          -> y do
            y << "the \"quickie\" \"microservice\""
          end
        end

        def __program_name
          "zingo fasto"
        end

        # --

        def __resolve_resources
          # near #masking
          io = @listener.call :resource, :line_downstream_for_help
          if io
            @stderr = io ; ACHIEVED_
          end
        end

      # -
    end
  end
end
# :#tombstone-A: used to use [#tab-001.2] to express the help screen
