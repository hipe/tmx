module Skylab::Tabular

  # the nodes defined in this file all have one thing in common: they are
  # are part of the doc-test "demo" in the comment at the very top asset
  # node of this project. OK two things: none of them are used anywhere
  # in production.
  #
  # because they exist to demonstrate a general technique but are not
  # used in production, we have moved them all here so they don't
  # interrupt the flow of the production code at the top.
  #
  # one day DRY it up, but for now until the dust settles, they are
  # all stuffed away here.

  format_string_via_schema = nil

  Magnetics::LineStream_via_JustifiedPage_and_Demo = -> jc do

    # (this could be said to replace what was once [#001.A], a feature island)

    format_string = format_string_via_schema[ jc.schema ]

    jc.to_stringified_tuple_stream.map_by do |tuple|

      format_string % tuple.map { |x| x.content_as_string }
    end
  end

  format_string_via_schema = -> schema do

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

  Magnetics::JustifiedPage_via_StringifiedTupleStream_and_Demo = -> st do

    schema = Models::TableSchema.__new_mutable_
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

    Models_JustifiedPage___.new schema, stringified_tuples
  end

  Magnetics::StringifiedTupleStream_via_MixedTupleStream_and_Demo = -> st do

    st.map_by do |x_a|

      x_a.map do |x|
        Models_IndifferentStringifiedCel_via_Mixed___.new x
      end
    end
  end

  class Models_JustifiedPage___

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

  class Models_IndifferentStringifiedCel_via_Mixed___

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
# #history: broke out of core file to improve flow. (are demo-only)
