# #todo
#
# in spirit, this node (simple in its essence) fulfilled almost exactly
# our new requirement here for the new simplification underhaul of [pl].
#
# at first we thought this was a feature-island. then we realized it's
# *not* a feature island except for one client that we will soon overhaul
# anyway..
#
# but A) the sibling node [#007] (now "lazy index") has so minimal
# requirements of sunch a "pending process queue" that it just implements
# it itself FOR NOW
#
# and B) during transition, we still need this guy as-is for its last
# remaining (very legacy)
# client..
#
# there is a risk of violating the single responsibility there near (A)
# but at writing it's so short that we see it as permissable. but as such
# a time that it's not and (B) is no longer an issue, erase this comment
# and repurpose this node.

module Skylab::Plugin

  class Models::PendingProcessingQueue  # see [#013]

    class << self

      alias_method :build_for, :new
      private :new
    end  # >>

    def initialize inst

      @_queue = []
      @_client = inst
    end

    def clear
      @_queue.clear
      self
    end

    def accept_by & p

      d = ( a = ( @_receivers ||= [] ) ).length
      a[ d ] = p
      @_queue.push Common_::BoundCall[ nil, d, :call ]
      NIL_
    end

    def accept_method_call args, meth, & p
      @_queue.push Common_::BoundCall[ args, nil, meth, & p ]
      NIL_
    end

    def flush_until_nonzero_exitstatus

      es = nil
      begin
        if @_queue.length.zero?
          break
        end
        bc = @_queue.shift
        receiver_d = bc.receiver  # nonstandard use
        _rcvr = if receiver_d
          @_receivers.fetch receiver_d
        else
          @_client
        end
        es = _rcvr.send bc.method_name, * bc.args, & bc.block
        if es.nonzero?
          break
        end
        redo
      end  while nil
      es
    end
  end
end
