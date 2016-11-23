module Skylab::Tabular

  class Magnetics::SurveyedPage_via_MixedTupleStream < Common_::Actor::Monadic

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
      def initialize tu_st
        @mixed_tuple_stream = tu_st

        @__mesh = MESH___
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

        typified_tuples = []
        field_surveys = []

        mixed_tuple_st = remove_instance_variable :@mixed_tuple_stream
        mesh = remove_instance_variable :@__mesh

        begin
          if field_surveys.length < mixed_tuple.length

            ( mixed_tuple.length - field_surveys.length ).times do
              field_surveys.push Home_::Models::FieldSurvey.begin mesh
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

      MESH___ =
    Home_.lib_.basic::OMNI_TYPE_CLASSIFICATION_HOOK_MESH_PROTOTYPE.redefine do |defn|

      defn.add :nil do |o|
        o.choices.increment_number_of_nils
        :nil
      end

      defn.add :false do |o|
        o.choices.increment_number_of_booleans
        :boolean
      end

      defn.add :symbol do |o|
        o.choices.increment_number_of_symbols
        :symbol
      end

      defn.add :true do |o|
        o.choices.increment_number_of_booleans
        :boolean
      end

      defn.add :other do |o|
        o.choices.increment_number_of_others
        :other
      end

      defn.add :nonblank_string do |o|
        o.choices.on_nonblank_string o.value
        :string
      end

      defn.add :zero_length_string do |o|
        o.choices.on_zero_length_string
        :string
      end

      defn.add :nonzero_length_blank_string do |o|
        o.choices.on_nonzero_length_blank_string o.value
        :string
      end

      defn.add :zero do |o|
        o.choices.on_zero
        :zero
      end

      defn.add :positive_nonzero_integer do |o|
        o.choices.on_positive_nonzero_integer
        :nonzero_integer
      end

      defn.add :negative_nonzero_integer do |o|
        o.choices.on_negative_nonzero_integer
        :nonzero_integer
      end

      defn.add :positive_nonzero_float do |o|
        o.choices.on_positive_nonzero_float
        :nonzero_float
      end

      defn.add :negative_nonzero_float do |o|
        o.choices.on_negative_nonzero_float
        :nonzero_float
      end
    end

    # ==
  end
end
# tombstone: the only reference to [#001.I]
# #history: full rewrite from [br] to [tab].
