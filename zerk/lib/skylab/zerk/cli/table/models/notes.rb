module Skylab::Zerk

  module CLI::Table

    class Models::Notes  # 1x here 1x [tab]

      # poorly named mutable guy for aggretating statistics-like
      # information about the table (probably just visual metrics)

      # -
        def initialize
          @_a = []
          @the_most_number_of_columns_ever_seen = 0
        end

        def see_this_number_of_columns d
          if @the_most_number_of_columns_ever_seen < d
            @the_most_number_of_columns_ever_seen = d
          end
        end

        def for_field d
          @_a[ d ] ||= Note___.new d
        end

        attr_reader(
          :the_most_number_of_columns_ever_seen,
        )
      # -

      # ==

      class Note___

        # preserves across pages.

        def initialize d
          @defined_field_offset = d
          @widest_width_ever = 0
        end

        attr_writer(
          :widest_width_ever,
        )

        attr_reader(
          :defined_field_offset,
          :widest_width_ever,
        )
      end

      # ==
    end
  end
end
# #history: broke out private models corefile to be exposed
