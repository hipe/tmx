module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::Contextualized_Line_Stream_via_Inflected_Parts_and_Precontextualized_Line_Stream ; class << self

      def via_magnetic_parameter_store ps

        # mlp.prefix[0, 0] = "#{ _s }#{ SPACE_ }"  # ..

        pa = ps.inflected_parts.to_phrase_assembly__

        _s = Magnetics_::Subject_Association_String_via_Subject_Association_SMALL[ ps ]

        _p = -> lc do

          lc.mutate_line_parts_by do |mlp|

            pa.add_any_string _s

            pa.add_space_if_necessary

            _ = pa.flush_to_string

            mlp.prefixed_string = _
          end
          NIL_
        end

        Magnetics_::Contextualized_Line_Stream_via_First_Line_Proc_and_Precontextualized_Line_Stream[
          _p, ps.precontextualized_line_stream ]
      end

      alias_method :[], :via_magnetic_parameter_store
    end ; end
  end
end
# #history: born
