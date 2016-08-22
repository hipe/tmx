module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::Message_That_Is_Single_String_via_First_Line_Map ; class << self

      # (although this is an orphan, we want it to be on the filesystem
      # because we want it to be represented in the generated graph.
      # it's a #feature-island anyway, so the FS hit is negligible.)

      def via_magnetic_parameter_store ps

        ps.first_line_map[ NOTHING_ ]
      end

      alias_method :[], :via_magnetic_parameter_store
    end ; end
  end
end
# #history: born as exceptional orphan at switch advent
