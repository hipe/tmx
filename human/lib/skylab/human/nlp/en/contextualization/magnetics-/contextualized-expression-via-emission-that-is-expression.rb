module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::Contextualized_Expression_via_Emission_that_Is_Expression ; class << self

      def via_magnetic_parameter_store ps

        _ = Magnetics_::Precontextualized_Line_Stream_via_Emission_that_Is_Expression[ ps ]

        ps.precontextualized_line_stream = _

        # early in pipeline we touch the trilean whether or not we need it.

        if ! ps._magnetic_value_is_known_ :trilean
          # (hi.)
          # this nastiness will have to be accounted for by [#043].)
          if ps._magnetic_value_is_known_ :channel
            _x = Magnetics_::Trilean_via_Channel[ ps ]
            ps.trilean = _x
          end
        end

        # not all clients ask for contextualization and pass the necessary
        # parameters for all emissions - oldschool [br] uses this facility
        # only for [#043]:"B" events and doesn't pass a soft stack

        _st = __contextualized_line_stream_for ps

        ps.contextualized_line_stream = _st

        Magnetics_::Contextualized_Expression_via_Contextualized_Line_Stream[ ps ]
      end

      def __contextualized_line_stream_for ps

        if ps._magnetic_value_is_known_ :inflected_parts
          Magnetics_::Contextualized_Line_Stream_via_Inflected_Parts_and_Precontextualized_Line_Stream[ ps ]
        elsif ps._magnetic_value_is_known_ :selection_stack
          Magnetics_::Contextualized_Line_Stream_via_Precontextualized_Line_Stream_and_Selection_Stack[ ps ]
        else
          ps.precontextualized_line_stream
        end
      end

      alias_method :[], :via_magnetic_parameter_store
    end ; end
  end
end
