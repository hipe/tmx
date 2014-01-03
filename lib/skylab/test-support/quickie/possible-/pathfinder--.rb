module Skylab::TestSupport

  module Quickie

    module Possible_

      class Pathfinder_

        include Grid_Methods_

        def initialize y, graph, from_i, to_i, sig_a
          @grid = @path = nil
          @y, @graph, @from_i, @to_i, @sig_a = y, graph, from_i, to_i, sig_a
        end

        def execute
          resolve_path
          perform_execution_result
        end

        def execute_with_path_or_failure
          if (( r = execute ))
            [ r, @path ]
          else
            [ r, @grid ]
          end
        end

      private

        # central thesis: start from the beginning node. at each current node
        # resolve exactly zero or one move that you can make. the ambiguity of
        # having multiple agents express a move (even the same one) triggers a
        # soft error and halts further execution. stop when either you reach
        # the target or you cannot make any more moves. if you did not reach
        # the goal (for any of the above reasons), you will have whined
        # appropritely and the result is false. else you were silent and
        # result is true-ish.

        def resolve_path
          bep = @graph.fetch_eventpoint @from_i
          fep = @graph.fetch_eventpoint @to_i
          cep = bep ; path = Path_.new
          @t = Node_Transitions_.new @graph, @sig_a  # validate names early, even
          goal_id = fep.node_id
          until (( goal_reached = goal_id == cep.node_id ))
            (( move_pred = resolve_one_move_predicate cep )) or break
            path << move_pred
            cep = @graph.fetch_eventpoint move_pred.to_pred.to_i
          end
          if goal_reached
            @path = path
          end
          nil
        end

        def resolve_one_move_predicate ep
          if ! (( a = @t[ ep.node_id ] ))
            add_goal_not_met_frames
            add_frame say_agents, say::Got_passed_[ ep ]
            nil
          elsif 1 == a.length
            a.first
          else
            resolve_one_move_predicate_of_several_from_eventpoint a, ep
          end
        end

        def resolve_one_move_predicate_of_several_from_eventpoint a, ep
          aa = [ ]
          strength_h = ::Hash.new { |h, d| aa << d ; h[ d ] = [ ] }
          a.each do |pred|
            strength_h[ pred.strength ] << pred
          end
          top_strength = aa.max
          same_a = strength_h.fetch top_strength
          if 1 == same_a.length
            same_a.fetch 0  # then this must be trumping something
          else
            add_frame say::Agents_[ :inclusive, same_a.map( & :sig ) ],
              say::Ambiguity_[ ep, same_a ]
            false
          end
        end

        define_method :say, & Say_

        def say_agents
          say::Agents_[ :exclusive, @sig_a ]
        end

        def add_goal_not_met_frames
          ep = @graph.fetch_eventpoint @to_i
          if @sig_a.length.zero?
            add_frame say::Exist_[ :present ], say::Agents_[ :inclusive, @sig_a ]
              # "there are no active agents"
            add_frame say::System_[], say::Reach_[ ep ], say::So_[]
              # "so the system cannot reach the FINISHED state"
          else
            add_frame say_agents, say::Bring_[ ep ]
              # "none of the 3 agents brings the system to the FINISHED state"
          end
          nil
        end
      end

      class Pathfinder_::Path_
        def initialize
          @a = []
        end
        def length
          @a.length
        end
        def fetch idx
          @a.fetch idx
        end
        def map &blk
          @a.map( &blk )
        end
        def each &blk
          @a.each( & blk )
        end
        def get_a
          @a.dup
        end
        def << x
          @a << x
          nil
        end
      end

      class Pathfinder_::Node_Transitions_

        def initialize graph, sig_a
          @graph = graph
          @a = [ ] ; @h = { }
          sig_a.each do |sig|
            sig.each_pair do |node_i, pred_a|
              graph.fetch_eventpoint node_i  # validate the name
              pred_a.each do |pred|
                :from == pred.predicate_i or next
                check_transition pred
                add_transition node_i, pred
              end
            end
          end
          nil
        end

        def [] node_i
          @h.fetch( node_i ) { }
        end

      private

        def check_transition pred
          fep = @graph.fetch_eventpoint pred.from_i
          tep = @graph.fetch_eventpoint pred.to_pred.to_i
          fep.transitions_to? tep or raise "signature error - #{
            }#{ errmsg say::Client_[ pred.sig.client ],
              say::Transition_[ fep, tep ]  }"
          nil
        end

        define_method :add_transition, & Multi_add_
        define_method :errmsg, & Errmsg_
        define_method :say, & Say_
      end
    end
  end
end
