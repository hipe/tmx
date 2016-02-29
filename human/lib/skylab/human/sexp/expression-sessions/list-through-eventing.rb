module Skylab::Human

  module Sexp

    class Expression_Sessions::List_through_Eventing  # :[#053].

      # (see also a simpler form at [#ba-056])

      Callback_::Actor.call( self, :properties,
        :gets_under,
        :always_at_the_beginning,
        :iff_zero_items,
        :any_first_item,
        :any_subsequent_items,
        :at_the_end_iff_nonzero_items,
        :y,
        :flush,
      )

      class << self
        def expression_via_sexp_stream_ st
          new.___init_and_produce_via_etc st
        end
        private :new
      end  # >>

      def ___init_and_produce_via_etc st
        # (used to be #[#ca-063])
        init_ivars
        process_polymorphic_stream_fully st
        sanity_checks
        defaults
        self
      end

      attr_reader :count

      def duplicate
        dup
      end

      def new_with * x_a
        otr = dup
        otr.init_copy x_a
        otr
      end

      def initialize_copy _otr_
        @did_hack_gets_under = false
        @gets_under = nil
      end

    protected

      def init_copy x_a
        process_iambic_fully x_a
        nil
      end

    private

      def init_ivars
        @always_at_the_beginning = @any_first_item = nil
        @at_the_end_iff_nonzero_items = nil
        @gets_under = nil
        @iff_zero_items = nil
        @output_x = nil
        @y = nil
        rewind
        nil
      end

      def sanity_checks
        if @gets_under
          @gets_under.respond_to?( :gets ) or raise ::ArgumentError, "signature changed"
        end
      end

      def defaults
        @any_first_item.nil? and @any_first_item = DEFAULT_FIRST_ITEM__ ; nil
      end

      DEFAULT_FIRST_ITEM__ = -> y, x do
        y << x ; nil
      end

      def receive_first_gets
        @y ||= produce_yieldee_when_in_scan_mode
        if @always_at_the_beginning
          @always_at_the_beginning[ @y ]
        end
        x = @gets_under.gets
        if x
          first_item x
        else
          @method_i = :noop
          if @iff_zero_items
            @iff_zero_items[ @y ]
            @output_x and flush_one_output_item
          end
        end
      end

      def produce_yieldee_when_in_scan_mode
        # note that this is a closure that binds to this context and will
        # not survive the trip "correctly" if you dup this object.
        ::Enumerator::Yielder.new do |x|
          @output_x ||= ::String.new
          @output_x.concat x ; nil
        end
      end

      def noop
        nil  # (just to say hello to step-debugger)
      end

      def first_item x
        @count += 1
        @method_i = :receive_subsequent_gets
        @any_first_item[ @y, x ]
        @output_x and flush_one_output_item
      end

      def receive_subsequent_gets
        x = @gets_under.gets
        if x
          subsequent_item x
        else
          @method_i = :noop
          if @at_the_end_iff_nonzero_items
            @at_the_end_iff_nonzero_items[ @y ]
          end
          @output_x and flush_one_output_item
        end
      end

      def subsequent_item x
        @count += 1
        @any_subsequent_items[ @y, x ]
        @output_x and flush_one_output_item
      end

      def flush_one_output_item
        x = @output_x ; @output_x = nil ; x
      end

    public

      def gets
        send @method_i
      end

    # ~ experimental buffering mode:

      def flush
        puts nil
        x = @flush[ @y ]
        rewind
        x
      end

      def rewind
        @count = 0
        @method_i = :receive_first_gets
        self
      end

      def << x
        puts x  # result is nil
        self
      end

      def puts x
        @did_hack_gets_under ||= hack_gets_under
        @x = x
        send @method_i
      end

    private

      def hack_gets_under
        @gets_under = Getser___.new do
          x = @x ; @x = nil ; x
        end
        @y or init_ivars_when_in_buffer_mode
        true
      end

      class Getser___ < ::Proc
        alias_method :gets, :call
      end

      def init_ivars_when_in_buffer_mode
        @y = ::Enumerator::Yielder.new do |x|
          @buffer_x ||= ::String.new
          @buffer_x.concat x
        end
        @flush ||= produce_flush_proc ; nil
      end

      def produce_flush_proc
        -> y do
          x = @buffer_x ; @buffer_x = nil ; x
        end
      end
    end
  end
end
