require 'skylab/common'

module Skylab::Tabular

  # here's an example of making a pipeline and then using it:
  #
  #     pipe = Home_::Pipeline.define do |o|
  #       o << :StringifiedTupleStream_via_MixedTupleStream
  #       o << :JustifiedCollection_via_StringifiedTupleStream
  #       o << :LineStream_via_JustifiedCollection
  #     end
  #
  #     _tu_st = Home_::Common_::Stream.via_nonsparse_array(
  #       [ %w( Food Drink ), %w( donuts coffee ) ] )
  #
  #     st = pipe.call _tu_st
  #
  #     st.gets  # => "|   Food  |   Drink |"
  #     st.gets  # => "| donuts  |  coffee |"
  #     st.gets  # => nil

  class Pipeline

    class << self
      alias_method :define, :new
      undef_method :new
    end  # >>

    def initialize
      @_magnetics = []
      yield self
      @_magnetics.freeze
      freeze
    end

    # --

    def << sym
      @_magnetics.push Home_::Magnetics.const_get( sym, false ) ; nil
    end

    # --

    def call x
      @_magnetics.each do |mag|
        _x_ = mag[ x ]
        x = _x_
      end
      x
    end

    alias_method :[], :call
  end

  module Magnetics

    LineStream_via_JustifiedCollection = -> jc do

      # (this could be said to replace what was once [#001.A], a feature island)

      format_string = FormatString_via_Schema[ jc.schema ]

      jc.to_stringified_tuple_stream.map_by do |tuple|

        format_string % tuple.map { |x| x.content_as_string }
      end
    end

    FormatString_via_Schema = -> schema do  # 1x this file only

      field_schema_st = schema.to_field_schema_stream

      # -- pseudo-constants

      mod_minus = '%-' ; mod = '%'

      # -- pseudo-constants for now but not for ever

      first_separator = '| '  # ..
      normal_separator = '  |  '  # ..
      final_separator = ' |'  # ..

      separator = -> do
        separator = -> { normal_separator }
        first_separator
      end

      # --

      format = ""
      begin
        field_schema = field_schema_st.gets
        field_schema || break

        format << separator[]

        o = field_schema.shape_statistics

        modX = field_schema.align_left ? mod_minus : mod

        if o.is_numeric
          self._JUST_A_SKETCH
          if o.is_float
            # ..
            format << "#{ modX }#{ o.maximum_number_of_whole_digits }.#{
              }#{ o.interesting_number_of_fractional_digits }"
          else
            format << "#{ modX }#{ o.maximum_number_of_whole_digits }d"
          end
        else
          format << "#{ modX }#{ o.maximum_width_of_string_content }s"
        end
        redo
      end while above

      format << final_separator
      format
    end

    JustifiedCollection_via_StringifiedTupleStream = -> st do

      schema = Models_::Schema.new
      stringified_tuples = []

      begin
        tuple = st.gets
        tuple || break
        tuple.each_with_index do |cel, d|
          schema.see_string_content_width cel.string_width, d
        end
        stringified_tuples.push tuple
        redo
      end while above

      Models_::JustifiedCollection.new schema, stringified_tuples
    end

    StringifiedTupleStream_via_MixedTupleStream = -> st do

      st.map_by do |x_a|

        x_a.map do |x|
          Models_::IndifferentStringifiedCel_via_Mixed.new x
        end
      end
    end
  end

  module Models_

    # ==

    class JustifiedCollection

      def initialize schema, stringified_tuples
        @schema = schema
        @_stringified_tuples = stringified_tuples
      end

      def to_stringified_tuple_stream
        Stream_[ @_stringified_tuples ]
      end

      attr_reader(
        :schema,
      )
    end

    # ==

    class Schema

      def initialize
        @_field_schemas = []
      end

      # -- write

      def see_string_content_width w, d
        _touch_field_schema( d ).__see_string_content_width_ w
      end

      def _touch_field_schema d
        fs = @_field_schemas[d]
        if ! fs
          fs = FieldSchema___.new
          @_field_schemas[d] = fs
        end
        fs
      end

      # -- read

      def number_of_columns
        @_field_schemas.length
      end

      def to_field_schema_stream
        Stream_[ @_field_schemas ]
      end
    end

    # ==

    class FieldSchema___

      def initialize
        @shape_statistics = FOR_NOW_ALWAYS_FOR_STRING___.new
      end

      def __see_string_content_width_ w
        @shape_statistics.see_width w
      end

      def align_left
        false  # ..
      end

      attr_reader(
        :shape_statistics,
      )
    end

    class FOR_NOW_ALWAYS_FOR_STRING___  # eventually "statistics for strings"

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

    class IndifferentStringifiedCel_via_Mixed

      def initialize x
        @content_as_string = "#{ x }"
        @string_width = @content_as_string.length
      end

      attr_reader(
        :content_as_string,
        :string_width,
      )
    end
  end

  # ==

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p
  end

  # ==

  Common_ = ::Skylab::Common
  Home_ = self
  NOTHING_ = nil
end
