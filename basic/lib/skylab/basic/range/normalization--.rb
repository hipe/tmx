module Skylab::Basic

  module Range

    class Normalization__  # :+[#027]

      Attributes_actor_[ self ]

      class << self
        def new_with * x_a, & x_p
          o = super
          if o
            o.freeze  # :+[#036]
          end
          o
        end
      end  # >>

      def initialize & edit_p

        @on_event_selectively = nil  # none will be supported
        @qualified_knownness = nil
        instance_exec( & edit_p )
      end

      def accept_selective_listener_proc p
        @on_event_selectively = p
      end

    private

      def qualified_knownness=
        _receive_arg gets_one_polymorphic_value
      end

      def begin=
        _touch_current_mutable_range.set_begin gets_one_polymorphic_value
      end

      def end=
        _touch_current_mutable_range.set_end gets_one_polymorphic_value
      end

      def is=
        x = gets_one_polymorphic_value
        rng = _touch_current_mutable_range
        rng.set_begin x
        rng.set_end x
      end

      def or=
        _flush_some_current_mutable_range_to_or_list
      end

      def x=

        _x = gets_one_polymorphic_value
        _receive_value _x
      end

      def _touch_current_mutable_range
        @rng ||= Mutable_Range___.new
      end

    public

      def against_value x, & x_p

        otr = dup
        otr._receive_value x
        if x_p
          self._COVER_ME_and_complete_me  # the method is not written
          otr.accept_selective_listener_proc x_p
        end
        otr.execute
      end

      def execute

        if ! @qualified_knownness
          self._MODERNIZE_THIS_CALL
        end

        @rng and _flush_some_current_mutable_range_to_or_list

        __normal_normalize
      end

    private

      def _receive_value x

        _kn = Callback_::Qualified_Knownness.via_value_and_association(
          x, Home_.default_property )

        _receive_arg _kn
      end
      protected :_receive_value

      def _receive_arg arg
        @qualified_knownness = arg
        KEEP_PARSING_
      end


      def _flush_some_current_mutable_range_to_or_list
        @or_a ||= []
        @or_a.push @rng
        @rng = nil
        KEEP_PARSING_
      end

      def __normal_normalize

        ok = false
        x = @qualified_knownness.value_x

        @or_a.each do |range|
          d = range.compare x
          if d and d.zero?
            ok = true
            break
          end
        end

        if ok
          @qualified_knownness.to_knownness

        elsif @on_event_selectively
          @on_event_selectively.call :error, :not_in_range do
            Explanation__.new_with QKN__, @qualified_knownness, :or_a, @or_a
          end
        else

          UNABLE_
        end
      end

      QKN__ = :qualified_knownness

      Explanation__ = Callback_::Event.prototype_with(

        :actual_property_is_outside_of_formal_property_set,
        QKN__, nil,
        :or_a, nil,
        :error_category, :argument_error,
        :ok, false,

      ) do | y, o |

        adj_p_s_a = []
        o.or_a.each do | range |
          adj_p_s_a.push range.phrase_under self
        end

        qkn = o.send QKN__

        y << "#{ par qkn.association } must be #{ or_ adj_p_s_a }. #{
          }had #{ ick qkn.value_x }"
      end

      class Mutable_Range___

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
