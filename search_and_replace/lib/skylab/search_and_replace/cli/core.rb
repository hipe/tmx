module Skylab::SearchAndReplace

  module Modalities::CLI

    class << self
      def highlighting_expression_agent_instance
        @___hl_expag ||= Highlighting_Expag___.new
      end
    end  # >>

    class Highlighting_Expag___

      def map_match_line_stream st

        # produce a stream that "highlights" the entirety of each line in
        # the upstream in a manner that keeps any trailing newline sequence
        # out of the highlighted span so that any subsequent `puts`, `chomp`
        # etc will still behave as expected on a line that has been styled.
        #
        # this expag prototype is stateless and and as such the particular
        # styling of this highlight is for now hard-coded.

        st.map_by do | line |

          newline_seqence = Mutate_by_my_chomp_[ line ]

          "\e[1;32m#{ line }\e[0m#{ newline_seqence }"
        end
      end
    end

    if false  # #todo - near the end

      Actions = ::Module.new

      class Actions::Search_and_Replace < ::Skylab::Brazen::CLI::Action_Adapter

        def bound_call_via_bound_action_and_mutated_backbound_iambic

          rsx = @resources

          o = Custom_Client_.new
          o.on_event_selectively = handle_event_selectively
          o.pwd = rsx.bridge_for( :filesystem ).pwd
          o.serr = rsx.serr
          o.sin = rsx.sin
          o.to_bound_call
        end
      end

      class Custom_Client_

        attr_writer(
          :on_event_selectively,
          :pwd,
          :serr,
          :sin,
        )

        def initialize

          # (zerk passes a lot of handlers around from parent to child so
          #  functions like these are implemented as procs not methods)

          @handle_event_selectively_via_channel = -> i_a, & ev_p do

            @on_event_selectively.call( * i_a, & ev_p )
          end

          @primary_UI_yielder = ::Enumerator::Yielder.new do | s |

            @serr.puts s
          end
        end

        def to_bound_call
          Callback_::Bound_Call.via_receiver_and_method_name self, :run
        end

        def run

          @node_with_focus = S_and_R_::Zerk_Tree.new self

          begin

            @node_with_focus.before_focus
            ok = @node_with_focus.receive_focus
            if ok
              redo
            end
            break
          end while nil

          @node_with_focus.exitstatus
        end

        # ~ messages received as zerk parent from zerk child (#hook-outs)

        ## ~~ program flow

        def change_focus_to cx
          @node_with_focus = cx
          NIL_
        end

        ## ~~ resources in support of events & UI

        attr_reader(
          :handle_event_selectively_via_channel,
          :primary_UI_yielder,
          :serr,
          :sin )

        def expression_agent
          Home_.lib_.brazen::API.expression_agent_instance
        end

        ## ~~ identity & reflectors

        def is_agent
          false
        end

        def is_interactive
          true
        end
      end
    end
  end
end
