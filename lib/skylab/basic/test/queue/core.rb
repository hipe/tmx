module Skylab::Basic::TestSupport

  module Queue

    def self.[] tcc

      tcc.include self
    end

    def subject_module_

      Home_::Queue
    end

    # (the lack of modern namespace conventions below is only for
    #  allowing historic code to remain unchanged for now..)

    def action
      @action ||= __build_client_instance
    end

    def invoke
      @result = @action.__receive_execute
      NIL_
    end

    def __build_client_instance

      subject_class_.new
    end

    module Methods_to_Make_a_Client_Class_Testable

      def enqueue meth
        # (this is a bit of a stretch of going lengths to support legacy tests)
        if meth.respond_to? :call
          _action_queue.accept_by( & meth )
        else
          _action_queue.accept_method_call nil, meth
        end
      end

      def enqueue_with_args meth, * args
        _action_queue.accept_method_call args, meth
      end

      def _action_queue
        @_action_queue ||= __build_action_queue
      end

      def __build_action_queue
        Home_::Queue.build_for self
      end

      def __receive_execute
        @_action_queue.flush_until_nonzero_exitstatus
      end

      attr_reader :a

      def _push * sym_and_args
        ( @a ||= [] ).concat sym_and_args
        0
      end
    end
  end
end
