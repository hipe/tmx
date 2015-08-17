module Skylab::Basic

  class Queue  # see [#049]

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
      @_queue.push Bound_Call___.new( nil, d, :call )
      NIL_
    end

    def accept_method_call args, meth, & p
      @_queue.push Bound_Call___.new( args, nil, meth, & p )
      NIL_
    end

    def flush_until_nonzero_exitstatus

      es = nil
      begin
        if @_queue.length.zero?
          break
        end
        bc = @_queue.shift
        receiver_d = bc.receiver_identifier
        _rcvr = if receiver_d
          @_receivers.fetch receiver_d
        else
          @_client
        end
        es = _rcvr.send bc.method_name, * bc.args, & bc.proc
        if es.nonzero?
          break
        end
        redo
      end  while nil
      es
    end

    class Bound_Call___  # mentored by [#ca-059]

      attr_reader(
        :args,
        :method_name,
        :proc,
        :receiver_identifier,
      )

      def initialize args, id_x, method_name, & p

        @args = args
        @method_name = method_name
        @proc = p
        @receiver_identifier = id_x
      end
    end
  end
end
