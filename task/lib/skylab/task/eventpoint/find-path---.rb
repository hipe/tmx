class Skylab::Task

  class Eventpoint

    class Find_Path___

      include Worker_Methods_

      # (style below ranges from ancient to contemporary)

      # ->

        def initialize y, graph, from_i, to_i, sig_a

          @expression_grid  = nil
          @before_symbol = from_i
          @graph = graph
          @path = nil
          @after_symbol = to_i
          @sig_a = sig_a
          @y = y
        end

        def work_
          ok = ___resolve_path
          if ok
            Callback_::Known_Known[ @path ]
          else
            ok
          end
        end

        # central thesis: start from the beginning node. at each current node
        # resolve exactly zero or one move that you can make. the ambiguity of
        # having multiple agents express a move (even the same one) triggers a
        # soft error and halts further execution. stop when either you reach
        # the target or you cannot make any more moves. if you did not reach
        # the goal (for any of the above reasons), you will have whined
        # appropritely and the result is false. else you were silent and
        # result is true-ish.

        def ___resolve_path

          bep = @graph.fetch_eventpoint @before_symbol
          fep = @graph.fetch_eventpoint @after_symbol

          cep = bep ; path = Path___.new

          @t = Node_Transitions___.new @graph, @sig_a  # validate names early, even

          goal_id = fep.node_id

          until (( goal_reached = goal_id == cep.node_id ))
            (( move_pred = resolve_one_move_predicate cep )) or break
            path << move_pred
            cep = @graph.fetch_eventpoint move_pred.to_pred.after_symbol
          end

          if goal_reached
            @path = path
            ACHIEVED_
          else
            UNABLE_
          end
        end

        def resolve_one_move_predicate ep

          if ! (( a = @t[ ep.node_id ] ))
            add_goal_not_met_expression
            add_statementish_ _express_agents, express_( :Got_passed, ep )
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
            _ = express_ :Agents, :inclusive, same_a.map( & :sig )
            __ = express_ :Ambiguity, ep, same_a

            add_statementish_ _, __

            UNABLE_
          end
        end

        def _express_agents
          express_ :Agents, :exclusive, @sig_a
        end

        def add_goal_not_met_expression

          ep = @graph.fetch_eventpoint @after_symbol

          if @sig_a.length.zero?
            __when_etc ep
          else

            add_statementish_ _express_agents, express_( :Bring, ep )
              # "none of the 3 agents brings the system to the FINISHED state"
          end
          NIL_
        end

        def __when_etc ep

          _ = express_ :Exist, :present
          __ = express_ :Agents, :inclusive, @sig_a

          add_statementish_ _, __
            # "there are no active agents"

          add_statementish_(
            express_( :System ),
            express_( :Reach, ep ),
            express_( :So ))
            # "so the system cannot reach the FINISHED state"

          NIL_
        end

        # <-

      class Path___

        def initialize
          @_a = []
        end

        def length
          @_a.length
        end

        def fetch idx
          @_a.fetch idx
        end

        def map &blk
          @_a.map( &blk )
        end

        def each &blk
          @_a.each( & blk )
        end

        def to_stream
          Callback_::Stream.via_nonsparse_array @_a
        end

        def << x
          @_a.push x
          NIL_
        end
      end

      class Node_Transitions___

        include Worker_Methods_  # `express_`, `errmsg_` only

        def initialize graph, sig_a
          @graph = graph
          @a = [ ] ; @h = { }
          sig_a.each do |sig|
            sig.each_pair do |node_i, pred_a|
              graph.fetch_eventpoint node_i  # validate the name
              pred_a.each do |pred|
                :from == pred.predicate_i or next
                __check_transition pred
                __add_transition node_i, pred
              end
            end
          end
          nil
        end

        def [] node_i
          @h.fetch( node_i ) { }
        end

        def __check_transition pred

          fep = @graph.fetch_eventpoint pred.before_symbol

          tep = @graph.fetch_eventpoint pred.to_pred.after_symbol

          if ! fep.transitions_to? tep
            raise ___say_etc tep, fep, pred
          end
        end

        def ___say_etc tep, fep, pred

          _ = express_ :Client, pred.sig.client
          __ = express_ :Transition, fep, tep

          "signature error - #{ errmsg_ _, __ }"
        end

        define_method :__add_transition, & Multi_add_
      end
    end
  end
end
