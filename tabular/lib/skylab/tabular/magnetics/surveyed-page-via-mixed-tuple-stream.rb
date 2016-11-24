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
          fld_survey_cls = cx.field_survey_class
          mesh = cx.hook_mesh
        end

        @mixed_tuple_stream = tu_st

        @__field_survey_class = fld_survey_cls || Home_::Models::FieldSurvey
        @__mesh = mesh || HOOK_MESH___
      end

      def execute
        mixed_tuple = @mixed_tuple_stream.gets
        if mixed_tuple
          __when_one mixed_tuple
        else
          NOTHING_
        end
      end

      def __when_one mixed_tuple

        field_surveys = []
        typified_tuples = []

        field_survey_class = remove_instance_variable :@__field_survey_class
        mixed_tuple_st = remove_instance_variable :@mixed_tuple_stream
        mesh = remove_instance_variable :@__mesh

        begin
          if field_surveys.length < mixed_tuple.length

            ( mixed_tuple.length - field_surveys.length ).times do
              field_surveys.push field_survey_class.begin mesh
            end
          end

          mixed_memo = []
          type_memo = []

          mixed_tuple.each_with_index do |x, d|

            mixed_memo.push x
            type_memo.push field_surveys.fetch( d ).see_value x
          end

          typified_tuples.push Models_::TypifiedMixedTuple.new( type_memo, mixed_memo )

          mixed_tuple = mixed_tuple_st.gets
        end while mixed_tuple

        field_surveys.each( & :finish )

        SurveyedPage___.new field_surveys.freeze, typified_tuples.freeze
      end
    # -

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
