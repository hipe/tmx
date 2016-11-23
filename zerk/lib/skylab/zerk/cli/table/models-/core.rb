module Skylab::Zerk

  module CLI::Table

    Models_ = ::Module.new

    class Models_::Field

      def initialize x_a
        _define_or_redefine x_a
      end

      def redefine__ x_a
        dup._define_or_redefine x_a
      end

      def _define_or_redefine x_a

        @_scn = Common_::Polymorphic_Stream.via_array x_a
        begin
          send OPTIONS___.fetch @_scn.current_token
        end until @_scn.no_unparsed_exists
        remove_instance_variable :@_scn
        freeze
      end

      def initialize_copy _
        # @align, @label
        NOTHING_
      end

      # -- write

      OPTIONS___ = {
        left: :_at_align,
        label: :__at_label,
        right: :_at_align,
      }

      def __at_label
        @_scn.advance_one
        @label = @_scn.gets_one
      end

      def _at_align
        @align = @_scn.gets_one
      end

      # -- read

      attr_reader(
        :align,  # :left | :right
        :label,
      )
    end

    # ==

    class Models_::Notes  # 1x

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
        @_a[ d ] ||= Models_::Note___.new d
      end

      attr_reader(
        :the_most_number_of_columns_ever_seen,
      )
    end

    class Models_::Note___

      # preserves across pages.

      def initialize d
        @field_offset = d
        @widest_width_ever = 0
      end

      attr_writer(
        :widest_width_ever,
      )

      attr_reader(
        :field_offset,
        :widest_width_ever,
      )
    end
  end
end
# #tombstone: at full rewrite for [tab], field class, abstruse dep. injection fw
