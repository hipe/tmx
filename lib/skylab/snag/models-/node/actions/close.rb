module Skylab::Snag

  class Models_::Node

    class Actions::Close < Common_Action

      edit_entity_class(

        :desc, -> y do
          'close a node (remove tag #open and add tag #done)'
        end,

        :property, :downstream_identifier,
        :required, :property, :upstream_identifier,
        :required, :property, :node_identifier
      )

      def produce_result
        resolve_node_collection_and_node_then_
      end

      def via_node_collection_and_node_

        em = __build_error_mutator
        p = em.to_proc

        ok = @node.edit :remove, :tag, :open, & p

        ok_ = @node.edit :prepend, :tag, :done, :check_for_redundancy, & p

        # do we save the entity if it only partially worked? below we do a
        # :+[#br-086] ignore fuzzy failure for usability: must a "close"
        # accomplish both things if it to be considered a success? or is it
        # still useful if it only does one of the things? this is a soft
        # design choice manifested here (change between '||' and '&&'):

        if ok || ok_

          em.flush_any_errors_as_info
          persist_node_
        else
          em.flush_any_errors_as_errors
        end
      end

      def __build_error_mutator
        Error_Mutator___.new( & handle_event_selectively )
      end

      class Error_Mutator___

        def initialize & oes_p

          @error_potential_events = []

          @_oes_p = oes_p

          @to_proc = -> * i_a, & ev_p do

            if :error == i_a.first

              @error_potential_events.push i_a, ev_p
              UNABLE_
            else

              @_oes_p.call( * i_a, & ev_p )
            end
          end
        end

        attr_reader :to_proc

        def flush_any_errors_as_info

          @error_potential_events.each_slice 2 do | i_a, ev_p |

            @_oes_p.call :info, * i_a[ 1..-1 ] do

              ev_p[].new_with :ok, nil
            end
          end
          NIL_
        end

        def flush_any_errors_as_errors

          a = @error_potential_events
          if a.length.zero?
            ACHIEVED_
          else
            a.each_slice 2 do | i_a, ev_p |
              @_oes_p.call( * i_a, & ev_p )
            end
            UNABLE_
          end
        end
      end
    end
  end
end
