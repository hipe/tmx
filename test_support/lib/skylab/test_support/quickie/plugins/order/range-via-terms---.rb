module Skylab::TestSupport
  module Quickie
    class Plugins::Order

      class Range_via_terms___ < Common_::Actor::Monadic

        # assume that any "N" has been converted to a count number.
        #
        # map the terms that were entered in the following way:
        #
        #   • if the terms are "reverse-facing" (if the first is less than
        #     the other), make them forward facing but memo that this is
        #     reverse-facing.
        #
        #   • (otherwise) if one term was entered, make it two ("N" -> "N-N")
        #
        #   • convert ordinals to offsets: turn "1-N" to (0, (N-1))

        def initialize x
          @_pair_a = x
        end

        def execute

          a = remove_instance_variable :@_pair_a
          first_term, second_term = a

          if second_term
            if second_term.value_x < first_term.value_x
              do_reverse = true
              a.reverse!
            end
          else
            a.push first_term.dup
          end

          begin_, end_ = a.map do |term|
            term.value_x - 1  # go from ordinal to offset
          end

          @range = begin_ .. end_
          @do_reverse = do_reverse
          freeze
        end

        attr_reader(
          :do_reverse,
          :range,
        )
      end
    end
  end
end
