module Skylab::Zerk

  class NonInteractiveCLI

    const_get :When_Support_, false

    module When_Support_  # #[#sl-155]

      class Here_::When_ < Callback_::Actor::Monadic

        class Ended_at_Compound < self  # for #t6

          def sub_execute_

            @CLI.line_yielder << say_expecting_
          end
        end

        class Compound_followed_by_Dash < self  # for #t7

          def sub_execute_

            s = @CLI.current_token ; me = self

            @CLI.express_ do |y|
              y << "options cannot occur immediately after compound nodes (option: #{ ick s })"
              y << me.say_expecting_
            end
          end
        end

        class Unavailable < self  # 1x

          # this also encompases cases like missing required parameters.
          # has experimental sesssion-type pattern that uses each incoming
          # emission to help guage what exitstatus to use.

          def initialize( * )
            @_greatest_exitstatus = nil
            super
          end

          def execute
            self  # it's a long-running session (yeah kinda ick)
          end

          def on_unavailable__ i_a, & ev_p

            d = @CLI.exitstatus_for_ i_a.last
            if d
              if ! @_greatest_exitstatus || d > @_greatest_exitstatus
                @_greatest_exitstatus = d
              end
            end

            @CLI.handle_ACS_emission_ i_a, & ev_p  # result is unreliable
          end

          def finish

            @CLI.express_stack_invite_ :for_more

            if @_greatest_exitstatus
              @CLI.init_exitstatus_ @_greatest_exitstatus
            else
              self._COVER_ME  # you should set it to something
            end
            NIL_
          end
        end

        # -

          def initialize cli
            @CLI = cli
          end

          def execute

            sub_execute_

            @CLI.express_stack_invite_ :because, :argument

            @CLI.init_exitstatus_for_ :_parse_error_

            STOP_PARSING_
          end

          def say_expecting_

            _strmr =  @CLI.top_frame_.streamer_for_navigational_node_tickets_
            @node_a_ = _strmr.call.to_a

            s = if MAX_SPLAY_AMOUNT_ >= @node_a_.length
              ___say_complete_version
            else
              __say_ellipsified_version
            end
            remove_instance_variable :@node_a_
            s
          end

          def ___say_complete_version

            prp = @CLI.node_formal_property_

            _s_a = @node_a_.map( & _node_moniker )

            @CLI.expression_agent.calculate do
              "expecting #{ par prp }: { #{ _s_a * ' | ' } }"
            end
          end

          def __say_ellipsified_version

            prp = @CLI.node_formal_property_

            s_a = @node_a_[ 0 ... MAX_SPLAY_AMOUNT_ ].map( & _node_moniker )
            s_a.push ELLIPSIS_PART_

            @CLI.expression_agent.calculate do
              "expecting #{ par prp }: { #{ s_a * ' | ' } }"
            end
          end

          def _node_moniker
            Node_monikizer_[ @CLI.expression_agent ]
          end

        # -
      end
    end
  end
end
