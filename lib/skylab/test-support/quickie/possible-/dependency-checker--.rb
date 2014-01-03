module Skylab::TestSupport

  module Quickie

    module Possible_

      class Dependency_Checker_

        include Grid_Methods_

        def initialize y, graph, mutable_path, sig_a
          @grid = nil
          @y, @graph, @mutable_path, @sig_a = y, graph, mutable_path, sig_a
        end

        def execute_with_path_or_failure
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
          if ! @grid then
            [ true, @mutable_path ]
          else
            articulate
            [ false, @grid ]
          end
        end

      private

        def get_nodes_visited_by_path_h
          nodes_visited_by_path_h = { }
          @mutable_path.each do |pred|
            nodes_visited_by_path_h[ pred.to_i ] = true
          end
          nodes_visited_by_path_h
        end

        define_method :say, & Say_

        def check_sig_rely_node sig, node_i, _rely_a  # assume rely_a
          if ! @nodes_visited_by_path_h[ node_i ]
            add_frame say::Signature_[ sig ], say::Unmet_Reliance_[
              @graph.fetch_eventpoint( node_i ) ]
          end
        end

        def sig_had_no_effect sig, untouched_pred_a
          seen_h = ::Hash.new { |h, k| h[k] = true ; nil }
          ep_a = untouched_pred_a.reduce [] do |m, x|
            if ! seen_h[ x.node_i ]
              m << @graph.fetch_eventpoint( x.node_i )
            end
            m
          end
          @y << errmsg( say::Signature_[ sig ], say::Had_no_effect_[ ep_a ] )
          nil
        end
      end
    end
  end
end
