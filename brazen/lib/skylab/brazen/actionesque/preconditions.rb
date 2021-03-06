module Skylab::Brazen

  # ->

    module Actionesque::Preconditions

      class Produce_Box

        # assume nonzero length precondition id's
        # (we're
        # calling this the second known implementation of [#ta-005] pathfinding.)

        def initialize id_a, bx, id, action, kernel, & p

          @action = action
          @identifier_a = id_a
          @kernel = kernel
          @listener = p
          @self_id = id

          @box = if bx
            bx
          else
            Common_::Box.new
          end
        end

        def produce_box

          seen = {} ; done_h = @box.h_

          resolve_silo = -> me_id, id_a do

            # in the normal case, first resolve the preconditions, then the self

            me_k = me_id.full_name_symbol
            ok = true

            _seen_ = seen.fetch me_k do seen[ me_k ] = true ; false end
            _seen_ and self._DO_ME

            relies_on_self = false

            if id_a && id_a.length.nonzero?

              id_a.each do | id |

                k = id.full_name_symbol
                done_h.key? k and next

                if me_k == k
                  relies_on_self = true
                  next
                end
                _sub_silo = @kernel.silo_via_identifier id
                _id_a_ = _sub_silo.silo_module.preconditions
                ok = resolve_silo[ id, _id_a_ ]
                ok or break
              end
            end
            if ok
              x = if relies_on_self
                # resolve a self-reliance only after the other deps are done
                _me_silo = @kernel.silo_via_identifier me_id
                _me_silo.precondition_for_self @action, me_id, @box, & @listener
              else
                _silo = @kernel.silo_via_identifier me_id
                _silo.precondition_for @action, me_id, @box, & @listener
              end
              if x
                @box.add me_k, x
              else
                ok = x
              end
            end
            ok
          end

          x = resolve_silo[ @self_id, @identifier_a ]
          x and @box
        end
      end
    end
  # <-
end
# :+#tombstone: cyclic dependency event
