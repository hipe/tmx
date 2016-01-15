module Skylab::Zerk

  class NonInteractiveCLI

    const_get :When_Support_, false

    module When_Support_

      class Here_::When_ < Callback_::Actor::Monadic

        class Ended_at_Compound < self  # for #t6

          def sub_execute_

            @CLI.line_yielder << say_expecting_
          end
        end

        class Compound_followed_by_Dash < self  # for #t7

          def sub_execute_

            s = @CLI.current_token_ ; me = self

            @CLI.express_ do |y|
              y << "options cannot occur immediately after compound nodes (option: #{ ick s })"
              y << me.say_expecting_
            end
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

            _strmr =  @CLI.top_frame_.streamer_for_lookupable_non_primitives_
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
