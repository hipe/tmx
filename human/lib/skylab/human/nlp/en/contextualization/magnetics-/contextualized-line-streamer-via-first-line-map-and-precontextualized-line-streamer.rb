module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::Contextualized_Line_Streamer_via_First_Line_Map_and_Precontextualized_Line_Streamer ; class << self  # 2x

      def via_magnetic_parameter_store ps

        _flm = ps.first_line_map
        st_p = ps.precontextualized_line_streamer

        o = Home_::Sexp::Expression_Sessions::List_through_Eventing::Simple.begin

        o.on_first = -> line do

          _flm[ line ] || Home_._SANITY  # (no one should reduce the first line, right?)
        end

        o.on_subsequent = IDENTITY_

        -> do
          _st = st_p.call
          o.to_stream_around _st
        end
      end

      alias_method :[], :via_magnetic_parameter_store
    end ; end
  end
end
# #history: broke out of sibling "[etc]..and-selection-stack"
