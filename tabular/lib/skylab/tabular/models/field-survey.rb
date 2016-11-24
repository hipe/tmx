module Skylab::Tabular

  class Models::FieldSurvey

    # as it works out, this becomes the the authoritative source for how
    # mixed values are "typified" under this system.
    #
    # users could always inject over the hook mesh and/or the subject class
    # and "typify" the arbitrary values in arbitrary ways.

    class << self
      alias_method :begin, :new
      undef_method :new
    end  # >>

    # ==

    IS_NUMERIC = {  # use `fetch` to reflect with confidence
      string: false,
      symbol: false,
      nonzero_float: true,
      nonzero_integer: true,
      zero: true,
      boolean: false,
      nil: false,
      other: false,
    }

    # ==
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

      # -- probable calls back from above

      # ~ strings

      def on_typeish_string_nonzero_length_blank s
        maybe_widen_width_of_widest_string s.length
        @number_of_nonzero_length_blank_strings += 1
        :string
      end

      def on_typeish_string_nonblank s
        maybe_widen_width_of_widest_string s.length
        @number_of_nonblank_strings += 1
        :string
      end

      def on_typeish_string_zero_length
        @number_of_zero_length_strings += 1
        :string
      end

      def on_typeish_symbol sym  # (like string but less indexing here)
        @number_of_symbols += 1
        :symbol
      end

      def maybe_widen_width_of_widest_string len
        if @width_of_widest_string < len
          @width_of_widest_string = len
        end
      end

      # ~ floats

      def on_typeish_negative_nonzero_float f

        @number_of_negatives += 1
        @number_of_nonzero_floats += 1
        :nonzero_float
      end

      def on_typeish_positive_nonzero_float f

        @number_of_nonzero_floats += 1
        :nonzero_float
      end

      # ~ ints

      def on_typeish_negative_nonzero_integer d

        @number_of_negatives += 1
        @number_of_nonzero_integers += 1
        :nonzero_integer
      end

      def on_typeish_positive_nonzero_integer d

        @number_of_nonzero_integers += 1
        :nonzero_integer
      end

      # ~

      def on_typeish_zero number
        @number_of_zeros += 1
        :zero
      end

      # ~

      def on_typeish_boolean b
        @number_of_booleans += 1
        :boolean
      end

      def on_typeish_nil
        @number_of_nils += 1
        :nil
      end

      def on_typeish_other x
        @number_of_others += 1
        :other
      end

      # --

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
