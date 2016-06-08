class Skylab::Task
  # ->
    class Eventpoint

      class Check_dependencies___

        include Worker_Methods_

        # (most style below this line is ancient)

        def initialize y, graph, mutable_path, sig_a

          @expression_grid = nil
          @graph = graph
          @mutable_path = mutable_path
          @sig_a = sig_a
          @y = y
        end

        def work_

          @nodes_visited_by_path_h = get_nodes_visited_by_path_h

          rely_a = react_a = nil
          strength_h = {
            react: -> x { ( react_a ||= [ ] ) << x },
            rely: -> x { ( rely_a ||= [ ] ) << x }
          }.freeze

          @sig_a.each do |sig|
            sig_had_effect = false ; maybe_untouched_pred_a = nil
            sig.each_pair do |node_i, pred_a|
              rely_a = react_a = nil
              pred_a.each do |pred|
                if :depend != pred.predicate_i
                  next( sig_had_effect = true )
                end
                strength_h.fetch( pred.strength_i )[ pred ]
              end
              if rely_a
                sig_had_effect = true
                check_sig_rely_node sig, node_i, rely_a
              elsif ! sig_had_effect && react_a
                ( maybe_untouched_pred_a ||= [ ] ).concat react_a
              end
            end
            sig_had_effect or sig_had_no_effect sig, maybe_untouched_pred_a
          end

          if @expression_grid
            UNABLE_
          else
            Common_::Known_Known[ @mutable_path ]
          end
        end

      private

        def get_nodes_visited_by_path_h
          nodes_visited_by_path_h = { }
          @mutable_path.each do |pred|
            nodes_visited_by_path_h[ pred.after_symbol ] = true
          end
          nodes_visited_by_path_h
        end

        def check_sig_rely_node sig, node_i, _rely_a  # assume rely_a

          if ! @nodes_visited_by_path_h[ node_i ]

            _ = express_ :Signature, sig
            __ = express_ :Unmet_Reliance, @graph.fetch_eventpoint( node_i )

            add_statementish_ _, __
          end
        end

        def sig_had_no_effect sig, untouched_pred_a

          seen_h = ::Hash.new { |h, k| h[k] = true ; nil }

          ep_a = untouched_pred_a.reduce [] do |m, x|

            k = x.node_symbol

            if ! seen_h[ k ]
              m << @graph.fetch_eventpoint( k )
            end

            m
          end

          _ = express_ :Signature, sig
          __ = express_ :Had_no_effect, ep_a

          @y << errmsg_( _, __ )

          NIL_
        end
      end
    end
  # -
end
