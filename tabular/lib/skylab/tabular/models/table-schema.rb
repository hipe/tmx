module Skylab::Tabular

  class Models::TableSchema

    # this whole file is for tables with a declared schema (older school).
    # because this now appears indistinguishable in purpose from a
    # "table design" suggests that these two should be merged #todo

    class << self

      def define & p
        new.__init_via_definition p
      end

      def __new_mutable_
        new._init_as_mutable
      end

      private :new
    end  # >>

    # -

      def initialize
        NOTHING_
      end

      def __init_via_definition p
        @_receive_user_field = :__receive_first_user_field
        p[ self ]
        remove_instance_variable :@_receive_user_field
        @field_box.freeze
        self
      end

      def _init_as_mutable
        @field_box = Common_::Box.new
        self
      end

      # -- write

      def add_field_via_normal_name_symbol * args
        send @_receive_user_field, args
        NIL
      end

      def __receive_first_user_field args
        @field_box = Common_::Box.new
        @_receive_user_field = :__receive_user_field_normally
        send @_receive_user_field, args
      end

      def __receive_user_field_normally args

        fld = Models_FieldSchema__.new args
        @field_box.add fld.normal_name_symbol, fld
        NIL
      end

      def see_string_content_width w, d
        _touch_field_schema( d ).__see_string_content_width_ w
      end

      def _touch_field_schema d

        # ([co] box isn't designed to do sparsely positioned constituents
        #  but A) it might "work" anyway and B) it might never happen..)

        bx = @field_box
        k = bx.a_[ d ]
        if k
          fs = bx.h_.fetch k
        else
          fs = Models_FieldSchema__.new
          bx.add_at_offset d, d, fs
        end
        fs
      end

      # -- read

      def number_of_columns
        @field_box.length
      end

      def to_field_schema_stream
        @field_box.to_value_stream
      end

      attr_reader(
        :field_box,
      )

    # -

    # ==

    class Models_FieldSchema__

      def initialize args=nil

        if args
          @_scn = Common_::Scanner.via_array args
          @normal_name_symbol = @_scn.gets_one
          until @_scn.no_unparsed_exists
            send OPTIONS___.fetch @_scn.gets_one
          end
          remove_instance_variable :@_scn
        end

        @shape_statistics ||= Models_ShapeStatisticsForStrings___.new  # ..
      end

      # - define-time / write-time

      OPTIONS___ = {
        numeric: :__parse_numeric,
      }

      def __parse_numeric
        @shape_statistics = Models_ShapeStatisticsForNumerics___.new  # ..
        NIL
      end

      def __see_string_content_width_ w
        @shape_statistics.see_width w
      end

      # -- read-time

      def name
        @name ||= Common_::Name.via_variegated_symbol @normal_name_symbol
      end

      def align_left
        false  # ..
      end

      def is_numeric
        @shape_statistics.is_numeric
      end

      def normal_name_symbol
        @normal_name_symbol  # for now, empasize that it is not set
      end

      attr_reader(
        :shape_statistics,
      )
    end

    # ==

    class Models_ShapeStatisticsForNumerics___

      # (should move/merge with legacy..)

      def initialize
        NOTHING_  # for now..
      end

      def is_numeric
        true
      end
    end

    # ==

    class Models_ShapeStatisticsForStrings___

      def initialize
        @maximum_width_of_string_content = 0
      end

      def see_width d
        if @maximum_width_of_string_content < d
          @maximum_width_of_string_content = d
        end
        NIL
      end

      attr_reader(
        :maximum_width_of_string_content,
      )

      def is_numeric
        false
      end
    end

    # ==
  end
end
# #history: outgrew top node
