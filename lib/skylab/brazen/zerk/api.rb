module Skylab::Brazen

  module Zerk

    class API  # models one particular invocation of the API (a "call")

      class << self
        def produce_bound_call x_a, branch
          new( x_a, branch ).produce_bc
        end
      end

      Brazen_.event.sender self

      def initialize x_a, branch
        @scan = Callback_.iambic_scanner.new 0, x_a
        @node = branch
        nil
      end

      def produce_bc
        @reached_terminal_node = false
        ok = true
        while @scan.unparsed_exists
          ok = step
          ok or break
        end
        if ok
          when_input_is_exhausted
        else
          @result
        end
      end

    private

      def step
        @token = @scan.current_token
        if @node.is_branch
          via_token_and_branch_node_step
        else
          when_did_not_terminate_at_leaf_node
        end
      end

      def via_token_and_branch_node_step
        node = @node[ @token ]
        if node && ! node.is_navigational
          @scan.advance_one
          @node_ = node
          via_second_node_step
        else
          when_child_not_found
        end
      end

      def via_second_node_step
        if @node_.is_branch
          @node = @node_ ; @node_ = nil
          PROCEDE_  # bubble back up to the main loop
        else
          when_second_node_is_leaf
        end
      end

      def when_second_node_is_leaf
        ok = @node_.execute_via_iambic_stream @scan
        if ok
          if @node_.is_terminal_node
            @reached_terminal_node = true
          end
        else
          @result = ok
        end
        ok
      end

      def when_input_is_exhausted
        if @reached_terminal_node
          ACHIEVED_
        elsif @node.is_branch
          when_terminated_at_branch_node
        else
          UNABLE_ # may be never reached?
        end
      end

      def when_child_not_found

        _ev = build_not_OK_event_with :child_not_found,
            :name_i, @token,
            :did_you_mean_i_a, childs.map( & :name_i ) do |y, o|

          _s_a = o.did_you_mean_i_a.map do |i|
            val i
          end

          y << "child not found: #{ ick o.name_i } - did you mean #{
            }#{ or_ _s_a }?"
        end
        unable_because _ev
      end

      def when_did_not_terminate_at_leaf_node

        _ev = build_not_OK_event_with :xxx

        unable_because _ev
      end

      def when_terminated_at_branch_node

        _ev = build_not_OK_event_with :request_ended_prematurely,
          :name_i, @node.name_i,
          :did_you_mean_i_a, childs.map( & :name_i ) do |y, o|

          _s_a = o.did_you_mean_i_a.map do |i|
            val i
          end

          y << "premature end of '#{ o.name_i }' request - #{
           }did you mean #{ or_ _s_a }?"
        end
        unable_because _ev
      end

      def childs
        @node.child_stream.reduce_by do |cx|
          cx.is_executable && ! cx.is_navigational
        end.to_a
      end

      def unable_because ev
        @result = send_event ev
        UNABLE_
      end

      def event_receiver
        @node
      end
    end
  end
end
