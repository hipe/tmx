module Skylab::Tabular

  class Magnetics::SurveyedPage_via_MixedTupleStream

    class SurveyedPage___

      def initialize fs_a, cts
        @__typified_tuples = cts
        @field_surveys = fs_a
      end

      def to_typified_tuple_stream
        Stream_[ @__typified_tuples ]
      end

      def number_of_fields
        @field_surveys.length
      end

      attr_reader(
        :field_surveys,
      )
    end

    # -

      class << self
        def call tu_st, cx=nil
          new( tu_st, cx ).execute
        end
        alias_method :[], :call
        private :new
      end  # >>

      def initialize tu_st, cx

        if cx
          fo = cx.field_observers_array
          fld_survey_cls = cx.field_survey_class
          mesh = cx.hook_mesh
        end

        @mixed_tuple_stream = tu_st
        @the_most_cels_ever = 0

        @__field_observers_array = fo
        @__field_survey_class = fld_survey_cls || Home_::Models::FieldSurvey
        @__mesh = mesh || HOOK_MESH___
      end

      def execute
        mixed_tuple = @mixed_tuple_stream.gets
        if mixed_tuple
          __build_page mixed_tuple
        else
          NOTHING_
        end
      end

      def __build_page mixed_tuple

        seer = __seer

        mixed_tuple_st = remove_instance_variable :@mixed_tuple_stream

        begin
          seer.see mixed_tuple

          mixed_tuple = mixed_tuple_st.gets

        end while mixed_tuple

        fs = remove_instance_variable :@field_surveys
        fs.each( & :finish )

        SurveyedPage___.new fs, remove_instance_variable( :@_typified_tuples )
      end

      def __seer

        @field_surveys = []  # one per column
        @_typified_tuples = []  # one per row

        TraversalOfOneMixedTuple___.new self
      end

      def release_field_observers_array
        remove_instance_variable :@__field_observers_array
      end

      def widen to_length

        # any given tuple might have more or less items than any previous
        # tuple. (whether or not this is allowed is outside our scope).
        # but typically this is called only ever at the first tuple.

        times = to_length - @field_surveys.length

        times.times do
          @field_surveys.push @__field_survey_class.begin @__mesh
        end
        @the_most_cels_ever = @field_surveys.length
        NIL
      end

      def push_typified_mixed_tuple tmt
        @_typified_tuples.push tmt ; nil
      end

      attr_reader(
        :field_surveys,
        :the_most_cels_ever,
      )
    # -

    # ==

    class TraversalOfOneMixedTuple___

      # dup-and-mutate pattern

      def initialize cl

        @_client = cl

        fo_a = cl.release_field_observers_array
        if fo_a
          @__field_observers_array = fo_a
          @_push = :__push_when_some_fields_are_observed
        else
          @_push = :_push_normally
        end

        freeze
      end

      def see mt
        dup.__init( mt ).execute
      end

      def __init mt
        @mixed_tuple = mt
        @_number_of_cels = mt.length
        self
      end

      def execute

        __maybe_widen

        @_typified_mixeds = []

        field_surveys = @_client.field_surveys
        len = @_number_of_cels
        mixed_tuple = remove_instance_variable :@mixed_tuple
        d = 0

        until len == d
          x = mixed_tuple.fetch d
          _typeish_symbol = field_surveys.fetch( d ).see_value x
          send @_push, Home_::Models::Typified::Mixed[ _typeish_symbol, x ]
          d += 1
        end

        @_client.push_typified_mixed_tuple(
          Home_::Models_::TypifiedMixedTuple.new(
            remove_instance_variable( :@_typified_mixeds ).freeze ) )

        NIL
      end

      def __maybe_widen
        if @_number_of_cels > @_client.the_most_cels_ever
          @_client.widen @_number_of_cels
        end
      end

      def __push_when_some_fields_are_observed typified_mixed

        p = @__field_observers_array[ @_typified_mixeds.length ]

        # we MUST accept that the above array could change at any time
        # (so that :#spot-1 can work)

        if p
          p[ typified_mixed ]
        end

        _push_normally typified_mixed
      end

      def _push_normally typified_mixed
        @_typified_mixeds.push typified_mixed
      end
    end

    # ==

      HOOK_MESH___ =
    Home_.lib_.basic::OMNI_TYPE_CLASSIFICATION_HOOK_MESH_PROTOTYPE.redefine do |defn|

      defn.add :nil do |o|
        o.observer.on_typeish_nil
      end

      defn.add :false do |o|
        o.observer.on_typeish_boolean o.value
      end

      defn.add :symbol do |o|
        o.observer.on_typeish_symbol o.value
      end

      defn.add :true do |o|
        o.observer.on_typeish_boolean o.value
      end

      defn.add :other do |o|
        o.observer.on_typeish_other o.value
      end

      defn.add :nonblank_string do |o|
        o.observer.on_typeish_string_nonblank o.value
      end

      defn.add :zero_length_string do |o|
        o.observer.on_typeish_string_zero_length
      end

      defn.add :nonzero_length_blank_string do |o|
        o.observer.on_typeish_string_nonzero_length_blank o.value
      end

      defn.add :zero do |o|
        o.observer.on_typeish_zero o.value
      end

      defn.add :negative_nonzero_integer do |o|
        o.observer.on_typeish_negative_nonzero_integer o.value
      end

      defn.add :positive_nonzero_integer do |o|
        o.observer.on_typeish_positive_nonzero_integer o.value
      end

      defn.add :negative_nonzero_float do |o|
        o.observer.on_typeish_negative_nonzero_float o.value
      end

      defn.add :positive_nonzero_float do |o|
        o.observer.on_typeish_positive_nonzero_float o.value
      end
    end

    # ==
  end
end
# tombstone: the only reference to [#001.I]
# #history: full rewrite from [br] to [tab].
