module Skylab::Brazen

  module Zerk

    class API  # models one particular invocation of the API (a "call")

      class << self
        def produce_bound_call x_a, branch
          new( x_a, branch ).produce_bc
        end
      end

      Callback_::Event.selective_builder_sender_receiver self

      def initialize x_a, branch
        @scan = Callback_::Polymorphic_Stream.via_array x_a
        @node = branch
        @node.before_focus
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
          when_did_not_terminate_at_leaf_node  # ever called?
        end
      end

      def via_token_and_branch_node_step
        node = @node[ @token ]
        if node && ! node.is_navigational && node.can_receive_focus
          @scan.advance_one
          @node_ = node
          via_second_node_step
        else
          m = :"receive__#{ @token }__"
          if @node.respond_to? m
            @scan.advance_one
            @node.send m, @scan.gets_one
          else
            __when_child_not_found
          end
        end
      end

      def via_second_node_step
        if @node_.is_branch
          @node = @node_ ; @node_ = nil
          @node.before_focus
          PROCEDE_  # bubble back up to the main loop
        else
          when_second_node_is_leaf
        end
      end

      def when_second_node_is_leaf
        x = @node_.receive_polymorphic_stream @scan
        if @node_.is_terminal_node
          @reached_terminal_node = true
          @result = Callback_::Bound_Call.via_value x
          ok = ACHIEVED_
        else
          @result = x
          ok = x
        end
        ok
      end

      def when_input_is_exhausted
        if @reached_terminal_node
          @result
        elsif @node.is_branch
          when_terminated_at_branch_node
        else
          UNABLE_ # may be never reached?
        end
      end

      def __when_child_not_found
        @result = maybe_send_event :error do
          build_child_not_found_event
        end
        UNABLE_
      end

      def build_child_not_found_event

        build_not_OK_event_with :child_not_found,
            :name_symbol, @token,
            :did_you_mean_i_a, childs.map( & :name_symbol ) do |y, o|

          _s_a = o.did_you_mean_i_a.map do |i|
            val i
          end

          y << "child not found: #{ ick o.name_symbol } - did you mean #{
            }#{ or_ _s_a }?"
        end
      end

      def when_terminated_at_branch_node
        @result = maybe_send_event :error do
          build_request_ended_prematurely_event
        end
        UNABLE_
      end

      def build_request_ended_prematurely_event

        build_not_OK_event_with :request_ended_prematurely,
          :name_symbol, @node.name_symbol,
          :did_you_mean_i_a, childs.map( & :name_symbol ) do |y, o|

          _s_a = o.did_you_mean_i_a.map do |i|
            val i
          end

          y << "premature end of '#{ o.name_symbol }' request - #{
            }did you mean #{ or_ _s_a }?"
        end
      end

      def childs
        @node.child_stream.reduce_by do |cx|
          cx.can_receive_focus && ! cx.is_navigational
        end.to_a
      end

      def maybe_send_event * i_a, & ev_p
        @node.maybe_receive_unsigned_event_via_channel i_a, & ev_p
      end
    end
  end
end
