module Skylab::Tabular

  class Magnetics::PageSurvey_via_MixedTupleStream

    class PageSurvey___

      def initialize fs_a, tt_a
        @every_survey_of_every_field = fs_a  # frozen.
        @__typified_tuples = tt_a
      end

      def to_typified_tuple_stream
        Stream_[ @__typified_tuples ]
      end

      def number_of_all_fields
        @every_survey_of_every_field.length
      end

      attr_reader(
        :every_survey_of_every_field,
      )
    end

    # -
      class << self

        def call( * none_or_all, tu_st )

          case none_or_all.length
          when 2, 0  # :#here
          else raise ::ArgumentError
          end

          new( * none_or_all, tu_st ).execute
        end

        alias_method :[], :call
        private :new
      end  # >>

      def initialize is_first=nil, cx=nil, tu_st  # none or all per #here

        if cx

          if is_first
            hfh = cx.hook_for_special_headers_spot_in_first_page_ever
          end

          fo_a = cx.field_observers_array
          field_surveyor = cx.field_surveyor
          hfeop = cx.hook_for_end_of_page
        end

        if fo_a
          @__field_observers_array = fo_a
          @_receive_typified = :__receive_typified_when_some_fields_are_observed
        else
          @_receive_typified = :_receive_typified_normally
        end

        field_surveyor ||= Field_surveyor___[]

        @_field_survey_writer = FieldSurveyWriter___.new field_surveyor
        @__hook_for_end_of_page = hfeop
        @__hook_for_headers = hfh
        @__mixed_tuple_stream = tu_st
        @_the_most_number_of_cels_seen_on_this_page = 0
        @__typified_tuples = []
      end

      Field_surveyor___ = Lazy_.call do
        Field_surveyor_prototype_[].redefine do |o|
          o.hook_mesh = HOOK_MESH
        end
      end

      def execute

        st = remove_instance_variable :@__mixed_tuple_stream
        mixed_tuple = st.gets
        if mixed_tuple
          __see_every_input_tuple mixed_tuple, st
          __flush_page
        else
          NOTHING_  # hi.
        end
      end

      def __see_every_input_tuple mixed_tuple, mixed_tuple_st

        begin
          __see_mixed_tuple mixed_tuple
          mixed_tuple = mixed_tuple_st.gets
        end while mixed_tuple

        NIL
      end

      def __flush_page

        # now that we have traversed the whole page of input, the array's
        # positions no longer must correspond to positions of input tuples.
        # now, the hook-in can expand this array at arbitrary positions.

        fsw = remove_instance_variable :@_field_survey_writer

        tt = remove_instance_variable :@__typified_tuples

        hfeop = remove_instance_variable :@__hook_for_end_of_page
        hfh = remove_instance_variable :@__hook_for_headers

        if hfeop

          hfeop[ HookServicesForClient__.new( hfh, tt, fsw ) ]

        elsif hfh

          # (if you have headers but no summary fields, near [#ze-050.1])

          hfh[ HookServicesForClient__.new( NOTHING_, tt, fsw ) ]
        end

        _final_surveys = fsw.finish

        PageSurvey___.new _final_surveys, tt
      end

      def __see_mixed_tuple mixed_tuple

        len = mixed_tuple.length
        if @_the_most_number_of_cels_seen_on_this_page < len
          __widen_to len
        end

        @_typified_mixeds = []

        @_offset = len
        until @_offset.zero?
          @_offset -= 1
          _x = mixed_tuple.fetch @_offset
          _typi = @_field_survey_writer.
            see_then_typified_mixed_via_value_and_index _x, @_offset
          send @_receive_typified, _typi
        end

        _tm_a = remove_instance_variable :@_typified_mixeds
        @__typified_tuples.push Home_::Models_::TypifiedMixedTuple.new _tm_a

        NIL
      end

      def __receive_typified_when_some_fields_are_observed tm

        p = @__field_observers_array[ @_offset ]

        # we MUST accept that the above array could change at any time
        # (so that #spot-1 can work)

        if p
          p[ tm ]
        end

        _receive_typified_normally tm
      end

      def _receive_typified_normally tm
        @_typified_mixeds[ @_offset ] = tm
      end

      def __widen_to len

        # any given tuple might have more or less items than any previous
        # tuple. (whether or not this is allowed is outside our scope).
        # typically this is only called once per page, at the first tuple.

        _times = len - @_the_most_number_of_cels_seen_on_this_page
        @_the_most_number_of_cels_seen_on_this_page = len
        _times.times do
          @_field_survey_writer.__push_new_survey_
        end
        NIL
      end
    # -

    # ==

    class HookServicesForClient__  # summary fields are nasty

      def initialize pp, tt, fsw
        @field_survey_writer = fsw
        @HEADER_THING = pp
        @typified_tuples = tt
      end

      def peek_first_first_FOR_MOCK
        @typified_tuples.fetch( 0 ).peek_first_FOR_MOCK
      end

      attr_reader(
        :field_survey_writer,
        :HEADER_THING,
        :typified_tuples,
      )
    end

    # ==

    class FieldSurveyWriter___

      # while field surveys are editable they are editable,
      # but once the are not they are not.

      def initialize field_surveyor

        @_array = []
        @__field_surveyor = field_surveyor
      end

      def clear_these d_a
        d_a.each do |d|
          @_array.fetch( d ).clear_survey
        end
        NIL
      end

      def at_index_add_N_items at_index, n_times  # [ze]

        @_array[ at_index, 0 ] = n_times.times.map do
          _build_new_survey_for_input_offset NOTHING_
        end
      end

      def __push_new_survey_
        @_array.push _build_new_survey_for_input_offset @_array.length
        NIL
      end

      def _build_new_survey_for_input_offset d
        @__field_surveyor.build_new_survey_for_input_offset d
      end

      # -- read

      def see_then_typified_mixed_via_value_and_index x, d  # [ze]
        _typeish_symbol = @_array.fetch( d ).see_value x
        Home_::Models::Typified::Mixed[ _typeish_symbol, x ]
      end

      def to_field_survey_scanner  # CAREFUL - don't use this while it dups
        Common_::Polymorphic_Stream.via_array @_array
      end

      def dereference field_offset
        @_array.fetch field_offset
      end

      # --

      def finish

        # (tell each field survey that it can make its final tallies of
        #  derived values (eg. totals) etc.)

        remove_instance_variable :@__field_surveyor
        arr = remove_instance_variable :@_array
        arr.each( & :finish )
        arr.freeze
      end
    end

    # ==

      HOOK_MESH =
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
