module Skylab::Tabular

  class Models::FieldSurvey

    class << self
      alias_method :begin, :new
      undef_method :new
    end  # >>

    # -

      def initialize mesh
        @__mesh = mesh

        @number_of_booleans = 0
        @number_of_cels = 0
        @number_of_negatives = 0
        @number_of_nils = 0
        @number_of_nonblank_strings = 0
        @number_of_nonzero_integers = 0
        @number_of_nonzero_length_blank_strings = 0
        @number_of_nonzero_floats = 0
        @number_of_others = 0
        @number_of_symbols = 0
        @number_of_zero_length_strings = 0
        @number_of_zeros = 0
        @width_of_widest_string = 0
      end

      # -- mutate

      def see_value x
        @number_of_cels += 1
        @__mesh.against_value_and_choices x, self
      end

      def increment_number_of_booleans
        @number_of_booleans += 1
      end

      def increment_number_of_nils
        @number_of_nils += 1
      end

      def increment_number_of_others
        @number_of_others += 1
      end

      def increment_number_of_symbols
        @number_of_symbols += 1
      end

      # ~

      def on_nonblank_string s
        _maybe_widen_widest_string s
        @number_of_nonblank_strings += 1
      end

      def on_nonzero_length_blank_string s
        _maybe_widen_widest_string s
        @number_of_nonzero_length_blank_strings += 1
      end

      def _maybe_widen_widest_string s
        d = s.length
        if d > @width_of_widest_string
          @width_of_widest_string = d
        end
      end

      def on_zero_length_string
        @number_of_zero_length_strings += 1
      end

      # ~

      def on_zero
        @number_of_zeros += 1
      end

      def on_negative_nonzero_integer
        @number_of_negatives += 1
        @number_of_nonzero_integers += 1
      end

      def on_positive_nonzero_integer
        @number_of_nonzero_integers += 1
      end

      def on_negative_nonzero_float
        @number_of_negatives += 1
        @number_of_nonzero_floats += 1
      end

      def on_positive_nonzero_float
        @number_of_nonzero_floats += 1
      end

      def finish

        @number_of_blank_strings =
          @number_of_nonzero_length_blank_strings +
          @number_of_zero_length_strings

        @number_of_strings = @number_of_blank_strings +
          @number_of_nonblank_strings

        @number_of_numerics = @number_of_zeros +
          @number_of_nonzero_integers +
          @number_of_nonzero_floats

        remove_instance_variable :@__mesh

        freeze ; nil
      end

      # -- read

      attr_reader(
        :number_of_booleans,
        :number_of_blank_strings,
        :number_of_cels,
        :number_of_nils,
        :number_of_negatives,
        :number_of_nonblank_strings,
        :number_of_nonzero_integers,
        :number_of_nonzero_floats,
        :number_of_numerics,
        :number_of_others,
        :number_of_strings,
        :number_of_symbols,
        :number_of_zero_length_strings,
        :number_of_zeros,
        :width_of_widest_string,
      )

    # -
  end
end
# #tombstone: older model of type inference with platform class taxonomy
# #tombstone: doctest tests in comments (the test are still intact somewhere)
# #history: full rewrite from [br] to [tab].
