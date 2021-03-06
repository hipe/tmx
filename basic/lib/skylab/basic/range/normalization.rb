module Skylab::Basic

  module Range

    class Normalization  # ##[#fi-004]

      Attributes_actor_[ self ]

      class << self
        def with * x_a, & x_p
          o = super
          if o
            o.freeze  # ##[#fi-004.6]
          end
          o
        end
      end  # >>

      def initialize & p

        @listener = p
        @qualified_knownness = nil
      end

    private

      def qualified_knownness=
        _receive_qualified_knownness gets_one
      end

      def begin=
        _touch_current_mutable_range.set_begin gets_one
      end

      def end=
        _touch_current_mutable_range.set_end gets_one
      end

      def is=
        x = gets_one
        rng = _touch_current_mutable_range
        rng.set_begin x
        rng.set_end x
      end

      def or=
        _flush_some_current_mutable_range_to_or_list
      end

      def x=

        _x = gets_one
        _receive_value _x
      end

      def _touch_current_mutable_range
        @rng ||= Mutable_Range___.new
      end

    public

      def against_value x, & p
        _execute_by p do |o|
          o._receive_value x
        end
      end

      def normalize_qualified_knownness qkn, & p
        _execute_by p do |o|
          o._receive_qualified_knownness qkn
        end
      end

      def _execute_by p
        o = dup
        if p
          o.listener = p
        end
        yield o
        o.execute
      end

      def execute

        if ! @qualified_knownness
          self._MODERNIZE_THIS_CALL
        end

        @rng and _flush_some_current_mutable_range_to_or_list

        __normal_normalize
      end

    protected

      def _receive_value x

        _kn = Common_::QualifiedKnownKnown.via_value_and_association(
          x, Home_.default_property )

        _receive_qualified_knownness _kn
      end

      def _receive_qualified_knownness qkn
        @qualified_knownness = qkn
        KEEP_PARSING_
      end

      attr_writer(
        :listener,
      )

    private

      def _flush_some_current_mutable_range_to_or_list
        @or_a ||= []
        @or_a.push @rng
        @rng = nil
        KEEP_PARSING_
      end

      def __normal_normalize

        ok = false
        x = @qualified_knownness.value

        @or_a.each do |range|
          d = range.compare x
          if d and d.zero?
            ok = true
            break
          end
        end

        if ok
          @qualified_knownness.to_knownness

        else

          p = @listener
          if p
            p.call :error, :not_in_range do
              Explanation__.with QKN__, @qualified_knownness, :or_a, @or_a
            end
          end

          UNABLE_
        end
      end

      QKN__ = :qualified_knownness

      Explanation__ = Common_::Event.prototype_with(

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
          }had #{ ick qkn.value }"
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

      # ==
      # ==
    end
  end
end
