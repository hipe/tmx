module Skylab::Tabular

  class Magnetics::SurveyedPage_via_MixedTupleStream < Common_::Actor::Monadic

    class SurveyedPage___

      def initialize fs_a
        @FIELD_SURVEYS = fs_a
      end

      attr_reader(
        :FIELD_SURVEYS,
      )
    end

    # -
      def initialize tu_st
        @tuple_stream = tu_st

        @__mesh = MESH___
      end

      def execute

        field_surveys = []

        tuple_st = remove_instance_variable :@tuple_stream
        mesh = remove_instance_variable :@__mesh

        begin
          tuple = tuple_st.gets
          tuple || break

          if field_surveys.length < tuple.length

            ( tuple.length - field_surveys.length ).times do
              field_surveys.push Home_::Models::FieldSurvey.begin mesh
            end
          end

          tuple.each_with_index do |x, d|

            field_surveys.fetch( d ).see_value x
          end

          redo
        end while above

        field_surveys.each( & :finish )

        SurveyedPage___.new field_surveys.freeze
      end
    # -
    # ==

      MESH___ =
    Home_.lib_.basic::OMNI_TYPE_CLASSIFICATION_HOOK_MESH_PROTOTYPE.redefine do |defn|

      defn.add :nil do |o|
        o.choices.increment_number_of_nils
        NIL
      end

      defn.add :false do |o|
        o.choices.increment_number_of_booleans
        NIL
      end

      defn.add :symbol do |o|
        o.choices.increment_number_of_symbols
        NIL
      end

      defn.add :true do |o|
        o.choices.increment_number_of_booleans
        NIL
      end

      defn.add :other do |o|
        o.choices.increment_number_of_others
        NIL
      end

      defn.add :nonblank_string do |o|
        o.choices.on_nonblank_string o.value
        NIL
      end

      defn.add :zero_length_string do |o|
        o.choices.on_zero_length_string
        NIL
      end

      defn.add :nonzero_length_blank_string do |o|
        o.choices.on_nonzero_length_blank_string o.value
        NIL
      end

      defn.add :zero do |o|
        o.choices.on_zero
        NIL
      end

      defn.add :positive_nonzero_integer do |o|
        o.choices.on_positive_nonzero_integer
        NIL
      end

      defn.add :negative_nonzero_integer do |o|
        o.choices.on_negative_nonzero_integer
        NIL
      end

      defn.add :positive_nonzero_float do |o|
        o.choices.on_positive_nonzero_float
        NIL
      end

      defn.add :negative_nonzero_float do |o|
        o.choices.on_negative_nonzero_float
        NIL
      end
    end

    # ==
  end
end
# tombstone: the only reference to [#001.I]
# #history: full rewrite from [br] to [tab].
