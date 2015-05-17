module Skylab::Basic

  module Range

    class Normalization__  # :+[#027]

      Callback_::Actor.methodic self, :properties,
        :on_event,
        :as_normal_value

      private

        def begin=
          touch_current_mutable_range.set_begin gets_one_polymorphic_value
        end

        def end=
          touch_current_mutable_range.set_end gets_one_polymorphic_value
        end

        def is=
          x = gets_one_polymorphic_value
          rng = touch_current_mutable_range
          rng.set_begin x
          rng.set_end x
        end

        def or=
          flush_some_current_mutable_range_to_or_list
        end

        # ~ for a particular act of normalization:

        def x=
          set_arg Callback_::Trio.new gets_one_polymorphic_value, true, Basic_.default_property
        end

        def arg=
          set_arg gets_one_polymorphic_value
        end

      # Callback_::Event.selective_builder_sender_receiver self

      def initialize & p
        @arg_was_provided = false
        @as_normal_value = @on_event = @rng = nil
        instance_exec( & p )
      end

      def touch_current_mutable_range
        @rng ||= Mutable_Range__.new
      end

      def flush_some_current_mutable_range_to_or_list
        @or_a ||= []
        @or_a.push @rng
        @rng = nil
        KEEP_PARSING_
      end

      def set_arg arg
        @arg_was_provided = true
        @arg = arg
        KEEP_PARSING_
      end

    public

      def execute
        @rng and flush_some_current_mutable_range_to_or_list
        if @arg_was_provided
          if @as_normal_value
            via_three_normalize
          elsif @on_event
            via_two_normalize
          else
            via_one_normalize
          end
        else
          self  # :+[#036]
        end
      end

      def is_valid x
        otr = dup
        otr.init_copy_with :x, x
        otr.execute_is_valid
      end

      def any_error_event_via_validate_x x
        otr = dup
        otr.init_copy_with :x, x
        otr.via_one_normalize
      end

    protected

      def init_copy_with * x_a
        process_polymorphic_stream_fully polymorphic_stream_via_iambic x_a ; nil
      end

      def execute_is_valid
        @on_event = NILADIC_FALSEHOOD_
        @as_normal_value = MONADIC_TRUTH_
        via_three_normalize
      end

      def via_one_normalize
        @on_event = IDENTITY_
        @as_normal_value = MONADIC_EMPTINESS_
        via_three_normalize
      end

    private

      def via_two_normalize
        @as_normal_value = IDENTITY_
        via_three_normalize
      end

      def via_three_normalize
        ok = false
        x = @arg.value_x
        @or_a.each do |range|
          d = range.compare x
          if d and d.zero?
            ok = true
            break
          end
        end
        if ok
          @as_normal_value[ x ]
        elsif @on_event.arity.zero?
          @on_event[]
        else
          @on_event[ build_explanation ]
        end
      end

    private

      def build_explanation
        Explanation__.new_with :bp, @arg, :or_a, @or_a
      end

      Explanation__ = Callback_::Event.prototype_with(
        :actual_property_is_outside_of_formal_property_set,
          :bp, nil, :or_a, nil ) do |y, o|

        adj_p_s_a = []
        o.or_a.each do |range|
          adj_p_s_a.push range.phrase_under self
        end

        y << "#{ par o.bp.property } must be #{ or_ adj_p_s_a }. #{
          }had #{ ick o.bp.value_x }"

      end

      class Mutable_Range__

        def initialize
          @begin_is_set = false
          @begin_is_unbound = true
          @end_is_set = false
          @end_is_unbound = true
          @is_of_width_one = false
        end

        attr_reader :begin_is_set, :begin_is_unbound, :begin_x,
          :end_is_set, :end_is_unbound, :end_x,

          :is_of_width_one

        def set_begin x
          @begin_is_set = true
          @begin_is_unbound = ! x
          if @end_is_set
            @is_of_width_one = ! @begin_is_unbound && @end_x == x
          end
          @begin_x = x
          KEEP_PARSING_
        end

        def set_end x
          @end_is_set = true
          @end_is_unbound = ! x
          if @begin_is_set
            @is_of_width_one = ! @end_is_unbound && @begin_x == x
          end
          @end_x = x
          KEEP_PARSING_
        end

        def compare x
          d = 0
          if ! @begin_is_unbound && @begin_x > x
            d = 1
          end
          if ! @end_is_unbound && @end_x < x
            if d.zero?
              d = -1
            else
              d = false
            end
          end
          d
        end

        def phrase_under expag
          if @is_of_width_one
            x = @begin_x
            expag.calculate do
              val x
            end
          elsif @begin_is_unbound
            if @end_is_unbound
              "any value"
            else
              x = @end_d
              expag.calculate do
                "less than or equal to #{ val x }"
              end
            end
          elsif @end_is_unbound
            x = @begin_x
            expag.calculate do
              "greater than or equal to #{ val x }"
            end
          else
            if @end_x < @begin_x
              _imp = " (which is impossible)"
            end
            b_x = @begin_x ; e_x = @end_x
            expag.calculate do
              "between #{ val b_x } and #{ val e_x } inclusive#{ _imp }"
            end
          end
        end
      end
    end
  end
end
